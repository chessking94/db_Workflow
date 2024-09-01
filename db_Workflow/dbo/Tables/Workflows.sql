CREATE TABLE [dbo].[Workflows]
(
	[workflowID] SMALLINT IDENTITY(1,1) NOT NULL,
	[workflowName] VARCHAR(50) NOT NULL,
	[workflowDescription] VARCHAR(100) NOT NULL,
	[workflowActive] BIT CONSTRAINT [DF_Workflows_Active] DEFAULT ((0)) NOT NULL,
	[workflowCreateDate] DATETIME CONSTRAINT [DF_Workflows_CreateDate] DEFAULT (GETDATE()) NOT NULL,
	[scheduleID] INT NULL,
	CONSTRAINT [PK_Workflows] PRIMARY KEY CLUSTERED ([workflowID] ASC),
	CONSTRAINT [UC_Workflows_Name] UNIQUE NONCLUSTERED ([workflowName] ASC),
	CONSTRAINT [FK_Workflows_scheduleID] FOREIGN KEY ([scheduleID]) REFERENCES [dbo].[Schedules] ([scheduleID])
);


GO
CREATE TRIGGER [dbo].[TRG_Workflows_AfterUpdate] ON [dbo].[Workflows]
AFTER UPDATE

AS

BEGIN
	DECLARE @workflowID SMALLINT

	DECLARE workflow_cursor CURSOR FOR SELECT workflowID FROM inserted
	OPEN workflow_cursor
	FETCH NEXT FROM workflow_cursor INTO @workflowID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @newscheduleID INT
		DECLARE @workflowActive BIT

		SELECT
		@newscheduleID = scheduleID,
		@workflowActive = workflowActive

		FROM inserted

		WHERE workflowID = @workflowID

		DECLARE @oldscheduleID INT

		IF UPDATE(scheduleID)
		BEGIN
			--delete any pending events
			EXEC dbo.cancelPendingWorkflowEvents @workflowID = @workflowID

			--if update is to a non-null value, reschedule events if workflow is active
			IF (@newscheduleID IS NOT NULL) AND (@workflowActive = 1)
			BEGIN
				EXEC dbo.scheduleChanged @scheduleID = @newscheduleID
			END
		END

		FETCH NEXT FROM workflow_cursor INTO @workflowID
	END

	CLOSE workflow_cursor
	DEALLOCATE workflow_cursor
END
