CREATE TABLE [dbo].[Events]
(
	[eventID] INT IDENTITY(1,1) NOT NULL,
	[eventCreateDate] DATETIME CONSTRAINT [DF_Events_CreateDate] DEFAULT (getdate()) NOT NULL,
	[workflowID] SMALLINT NULL,
	[stepNumber] TINYINT NULL,
	[actionID] INT NOT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[eventStatusID] SMALLINT CONSTRAINT [DF_Events_Status] DEFAULT ((2)) NOT NULL,
	[eventStatusDate] DATETIME CONSTRAINT [DF_Events_StatusDate] DEFAULT (getdate()) NOT NULL,
	[eventStartDate] DATETIME CONSTRAINT [DF_Events_StartDate] DEFAULT (getdate()) NOT NULL,
	[eventEndDate] DATETIME NULL,
	[eventNote] VARCHAR(MAX) NULL,
    CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED ([eventID] ASC),
	CONSTRAINT [FK_Events_Actions] FOREIGN KEY ([actionID]) REFERENCES [dbo].[Actions] ([actionID]),
	CONSTRAINT [FK_Events_EventStatuses] FOREIGN KEY ([eventStatusID]) REFERENCES [dbo].[EventStatuses] ([eventStatusID]),
	CONSTRAINT [FK_Events_Workflows] FOREIGN KEY ([workflowID]) REFERENCES [dbo].[Workflows] ([workflowID]) 
	--intentionally not making a FK to WorkflowActions in case step numbering changes
);


GO
CREATE NONCLUSTERED INDEX [IDX_Events_actionID]
    ON [dbo].[Events]([actionID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Events_eventStatusStart]
    ON [dbo].[Events]([eventStatusID] ASC, [eventStartDate] ASC);


GO
CREATE TRIGGER [dbo].[TRG_Events_BeforeUpdate] ON [dbo].[Events]

INSTEAD OF UPDATE

AS

BEGIN
	--need to include all fields in the table here
	UPDATE e
	SET e.eventCreateDate = i.eventCreateDate,
		e.workflowID = i.workflowID,
		e.stepNumber = i.stepNumber,
		e.actionID = i.actionID,
		e.eventParameters = i.eventParameters,
		e.eventStatusID = i.eventStatusID,
		e.eventStatusDate = i.eventStatusDate,
		e.eventStartDate = i.eventStartDate,
		e.eventEndDate = i.eventEndDate,
		e.eventNote = i.eventNote

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID
	JOIN inserted i ON e.eventID = i.eventID

	WHERE es.isTerminal = 0  --only allow updates to records not already marked in a terminal status
END


GO
CREATE TRIGGER [dbo].[TRG_Events_AfterUpdate] ON [dbo].[Events]
AFTER UPDATE

AS

IF UPDATE(eventStatusID)
BEGIN
	--update dates
	UPDATE e
	SET e.eventStatusDate = GETDATE(),
		e.eventStartDate = (CASE WHEN es.inProgress = 1 THEN GETDATE() ELSE e.eventStartDate END),
		e.eventEndDate = (CASE WHEN es.isTerminal = 1 THEN GETDATE() ELSE NULL END)

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID
	JOIN inserted i ON
		e.eventID = i.eventID

	--cancel remaining workflow steps after an error if not configured to continue
	UPDATE dbo.Events
	SET eventStatusID = 0,
		--since this is in a trigger, need to set the status and end dates directly (trigger won't fire the trigger)
		eventStatusDate = GETDATE(),
		eventEndDate = GETDATE(),
		eventNote = 'Previous workflow step error'
	
	WHERE eventID IN (
		SELECT
		e.eventID

		FROM inserted i
		JOIN dbo.WorkflowActions wa ON
			i.workflowID = wa.workflowID
			AND i.stepNumber = wa.stepNumber
		JOIN dbo.Events e ON
			i.workflowID = e.workflowID
		JOIN dbo.EventStatuses es ON
			e.eventStatusID = es.eventStatusID

		WHERE i.eventStatusID = -1  --incoming update was an error
		AND wa.continueAfterError = 0  --workflow step is defined as not continuing after an error
		AND es.inProgress = 0  --remaining workflow steps have not started yet
		AND es.isTerminal = 0  --remaining workflow steps have not completed yet
		AND e.eventID NOT IN (SELECT eventID FROM inserted)  --safeguard to exclude the original record being updated
	)
END;
