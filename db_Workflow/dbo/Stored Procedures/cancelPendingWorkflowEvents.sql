CREATE PROCEDURE [dbo].[cancelPendingWorkflowEvents]
	@workflowID SMALLINT
AS

BEGIN
	IF EXISTS (SELECT e.eventID FROM dbo.Events e JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID WHERE e.workflowID = @workflowID AND e.stepNumber = 1 AND es.isTerminal = 0 AND es.inProgress = 0)
	BEGIN
		DECLARE @eventsToCancel TABLE (eventID INT)

		INSERT INTO @eventsToCancel
		SELECT
		e.eventID
			
		FROM dbo.Events e
		JOIN dbo.EventStatuses es ON
			e.eventStatusID = es.eventStatusID
			
		WHERE e.workflowID = @workflowID
		AND es.isTerminal = 0
		AND es.inProgress = 0
			
		ORDER BY e.eventID

		DECLARE @eventID INT
		SET @eventID = (SELECT TOP 1 eventID FROM @eventsToCancel)
		WHILE @eventID IS NOT NULL
		BEGIN
			EXEC dbo.updateEventStatus @eventID = @eventID, @eventStatus = 'Cancelled', @eventNote = 'Schedule changed'

			DELETE FROM @eventsToCancel WHERE eventID = @eventID
			SET @eventID = (SELECT TOP 1 eventID FROM @eventsToCancel)
		END
	END
END
