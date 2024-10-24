CREATE PROCEDURE [dbo].[scheduleChanged] (
	@scheduleID INT
)

AS

BEGIN
	DECLARE @impactedWorkflows TABLE (workflowID SMALLINT)

	INSERT INTO @impactedWorkflows
	SELECT workflowID FROM dbo.Workflows WHERE scheduleID = @scheduleID

	DECLARE @workflowID SMALLINT
	SET @workflowID = (SELECT TOP 1 workflowID FROM @impactedWorkflows)
	WHILE @workflowID IS NOT NULL
	BEGIN
		--cancel any unstarted complete workflows for that schedule (if step 1 has started, do not cancel steps 2+ but simply do nothing)
		EXEC dbo.cancelPendingWorkflowEvents @workflowID = @workflowID

		--if no pending workflow steps, reschedule workflows for that schedule
		IF (SELECT scheduleActive FROM dbo.Schedules WHERE scheduleID = @scheduleID) = 1
		BEGIN
			DECLARE @pendingEvents INT = 0
			SELECT
			@pendingEvents = COUNT(e.eventID)

			FROM dbo.Events e
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

		--prep for next iteration
		DELETE FROM @impactedWorkflows WHERE workflowID = @workflowID
		SET @workflowID = (SELECT TOP 1 workflowID FROM @impactedWorkflows)
	END
END
