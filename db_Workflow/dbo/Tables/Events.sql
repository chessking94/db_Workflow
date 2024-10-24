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

	--reschedule workflow if it it complete; even though it is unlikely, need to use a cursor to iterate over the affected rows
	DECLARE @eventID INT
	DECLARE eventCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT i.eventID FROM inserted i
	FOR READ ONLY

	OPEN eventCursor
	FETCH NEXT FROM eventCursor INTO @eventID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @rescheduleWorkflow BIT = 0
		DECLARE @workflowID SMALLINT
		DECLARE @scheduleID INT

		SELECT
		@rescheduleWorkflow = (CASE WHEN w.workflowActive = 1 AND s.scheduleActive = 1 THEN 1 ELSE 0 END),
		@workflowID = w.workflowID,
		@scheduleID = s.scheduleID

		FROM inserted i
		LEFT JOIN dbo.Workflows w ON
			i.workflowID = w.workflowID
		LEFT JOIN dbo.Schedules s ON
			w.scheduleID = s.scheduleID

		WHERE i.eventID = @eventID

		IF @rescheduleWorkflow = 1
		BEGIN
			DECLARE @pendingEvents INT = 0
			SELECT
			@pendingEvents = COUNT(e.eventID)

			FROM inserted i
			JOIN dbo.Events e ON
				i.eventID = e.eventID
			JOIN dbo.EventStatuses es ON
				e.eventStatusID = es.eventStatusID

			WHERE e.workflowID = @workflowID
			AND es.isTerminal = 0

			IF @pendingEvents = 0
			BEGIN
				DECLARE @workflowName VARCHAR(50) = (SELECT workflowName FROM dbo.Workflows WHERE workflowID = @workflowID)
				DECLARE @nextRunTime DATETIME = dbo.scheduleNextRunTime(@scheduleID)

				EXEC dbo.createEvent @workflowName = @workflowName, @eventStartDate = @nextRunTime
			END
		END

		FETCH NEXT FROM eventCursor INTO @eventID
	END

	CLOSE eventCursor
	DEALLOCATE eventCursor
END;
