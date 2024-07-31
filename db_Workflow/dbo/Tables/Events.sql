CREATE TABLE [dbo].[Events]
(
	[eventID] INT IDENTITY(1,1) NOT NULL,
	[eventCreateDate] DATETIME CONSTRAINT [DF_Events_CreateDate] DEFAULT (getdate()) NOT NULL,
	[actionID] INT NOT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[eventStatusID] SMALLINT CONSTRAINT [DF_Events_Status] DEFAULT ((0)) NOT NULL,
	[eventStatusDate] DATETIME CONSTRAINT [DF_Events_StatusDate] DEFAULT (getdate()) NOT NULL,
	[eventStartDate] DATETIME CONSTRAINT [DF_Events_StartDate] DEFAULT (getdate()) NOT NULL,
	[eventEndDate] DATETIME NULL,
	[eventError] VARCHAR(MAX) NULL,
    CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED ([eventID] ASC),
	CONSTRAINT [FK_Events_actionID] FOREIGN KEY ([actionID]) REFERENCES [dbo].[Actions] ([actionID]),
	CONSTRAINT [FK_Events_eventStatusID] FOREIGN KEY ([eventStatusID]) REFERENCES [dbo].[EventStatuses] ([eventStatusID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_Events_actionID]
    ON [dbo].[Events]([actionID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Events_eventStatusStart]
    ON [dbo].[Events]([eventStatusID] ASC, [eventStartDate] ASC);


GO
CREATE TRIGGER [dbo].[TRG_Events_AfterUpdate] ON [dbo].[Events]
AFTER UPDATE

AS

IF UPDATE(eventStatusID)
BEGIN
	UPDATE e
	SET e.eventStatusDate = GETDATE(),
		e.eventEndDate = (CASE WHEN es.isTerminal = 1 THEN GETDATE() ELSE NULL END)
	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID
	JOIN inserted i ON e.eventID = i.EventID
END;


GO
CREATE TRIGGER [dbo].[TRG_Events_BeforeUpdate] ON [dbo].[Events]

INSTEAD OF UPDATE

AS

BEGIN
	--need to include all fields in the table here
	UPDATE e
	SET e.eventCreateDate = i.eventCreateDate,
		e.actionID = i.actionID,
		e.eventParameters = i.eventParameters,
		e.eventStatusID = i.eventStatusID,
		e.eventStatusDate = i.eventStatusDate,
		e.eventStartDate = i.eventStartDate,
		e.eventEndDate = i.eventEndDate,
		e.eventError = i.eventError
	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID
	JOIN inserted i ON e.eventID = i.EventID
	WHERE es.isTerminal = 0  --only allow updates to records not already marked in a terminal status
END
