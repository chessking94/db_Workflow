CREATE TABLE [dbo].[Schedules]
(
	[scheduleID] INT IDENTITY(1,1) NOT NULL,
	[scheduleName] VARCHAR(50) NOT NULL,
	[scheduleCreateDate] DATETIME CONSTRAINT [DF_Schedules_CreateDate] DEFAULT ((GETDATE())) NOT NULL,
	[scheduleActive] BIT CONSTRAINT [DF_Schedules_Active] DEFAULT ((0)) NOT NULL,
	[scheduleStartDate] DATE NOT NULL,
	[scheduleEndDate] DATE NULL,
	[scheduleRunTime] TIME(0) NOT NULL,
    [recurrenceID] TINYINT NULL, 
    [recurrenceInterval] TINYINT NULL,
    CONSTRAINT [PK_Schedules] PRIMARY KEY CLUSTERED ([scheduleID] ASC),
	CONSTRAINT [UC_Schedules_Name] UNIQUE NONCLUSTERED ([scheduleName] ASC),
	CONSTRAINT [FK_Schedules_Recurrences] FOREIGN KEY ([recurrenceID]) REFERENCES dbo.Recurrences([recurrenceID]),
	CONSTRAINT [CHK_Schedules_recurrenceInterval] CHECK ([recurrenceInterval] BETWEEN 1 AND 59)
);


GO
CREATE TRIGGER [dbo].[TRG_Schedules_AfterInsert] ON [dbo].[Schedules]
AFTER INSERT

AS

BEGIN
	DECLARE @scheduleID INT

	DECLARE schedule_cursor CURSOR FOR SELECT scheduleID FROM inserted
	OPEN schedule_cursor
	FETCH NEXT FROM schedule_cursor INTO @scheduleID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.scheduleChanged @scheduleID = @scheduleID

		FETCH NEXT FROM schedule_cursor INTO @scheduleID
	END

	CLOSE schedule_cursor
	DEALLOCATE schedule_cursor
END;


GO
CREATE TRIGGER [dbo].[TRG_Schedules_AfterUpdate] ON [dbo].[Schedules]
AFTER UPDATE

AS

BEGIN
	DECLARE @scheduleID INT

	DECLARE schedule_cursor CURSOR FOR SELECT scheduleID FROM inserted
	OPEN schedule_cursor
	FETCH NEXT FROM schedule_cursor INTO @scheduleID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.scheduleChanged @scheduleID = @scheduleID

		FETCH NEXT FROM schedule_cursor INTO @scheduleID
	END

	CLOSE schedule_cursor
	DEALLOCATE schedule_cursor
END
