CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

--validation to determine if the event should be cancelled
DECLARE @cancelEvent BIT = 0
DECLARE @cancelEventReason VARCHAR(MAX)

----is action active?
IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = 1 - CAST(a.actionActive AS TINYINT)

	FROM dbo.Events e
	JOIN dbo.Actions a ON
		e.actionID = a.actionID

	WHERE e.eventID = @eventID

	IF @cancelEvent = 1 SET @cancelEventReason = 'Active inactive'
END

----is application active?
IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = 1 - CAST(ISNULL(app.applicationActive, 1) AS TINYINT)

	FROM dbo.Events e
	JOIN dbo.Actions a ON
		e.actionID = a.actionID
	LEFT JOIN dbo.Applications app ON
		a.applicationID = app.applicationID
	
	WHERE e.eventID = @eventID

	IF @cancelEvent = 1 SET @cancelEventReason = 'Application inactive'
END

IF @cancelEvent = 1
BEGIN
	EXEC updateEventStatus @eventID = @eventID, @eventStatus = 0, @eventError = @cancelEventReason
	SELECT 0
END
ELSE
BEGIN
	--not cancelling, validate now if the event can be started
	----is the event in a startable status?
	DECLARE @canStart BIT = 1
	IF @canStart = 1
		BEGIN
		SELECT
		@canStart = (CASE WHEN (es.inProgress = 1 OR es.isTerminal = 1) THEN 0 ELSE 1 END)

		FROM dbo.Events e
		JOIN dbo.EventStatuses es ON
			e.eventStatusID = es.eventStatusID

		WHERE e.eventID = @eventID
	END

	----if the event is for a workflow, ensure prerequisite step is complete
	IF (@canStart = 1 AND (SELECT workflowID FROM dbo.Events WHERE eventID = @eventID) IS NOT NULL)
	BEGIN
		SELECT
		@canStart = (
			CASE
				WHEN es.inProgress = 1 THEN 0
				WHEN es.eventStatusID = 2 THEN 0
				WHEN es.eventStatusID = -1 AND wa.continueAfterError = 0 THEN 0
				ELSE 1
			END
		)

		FROM dbo.Events e
		JOIN dbo.EventStatuses es ON
			e.eventStatusID = es.eventStatusID
		JOIN dbo.WorkflowActions wa ON
			e.workflowID = wa.workflowID
			AND e.stepNumber = wa.stepNumber

		WHERE e.stepNumber = (SELECT stepNumber FROM dbo.Events WHERE eventID = @eventID) - 1
	END

	----are too many instances of the action already running?
	IF @canStart = 1
	BEGIN
		SELECT
		CASE
			WHEN SUM(CAST(es.inProgress AS TINYINT)) < a.actionConcurrency THEN 1
			ELSE 0
		END AS canStartEvent

		FROM dbo.Events e
		JOIN dbo.EventStatuses es ON
			e.eventStatusID = es.eventStatusID
		JOIN dbo.Actions a ON
			e.actionID = a.actionID

		WHERE e.actionID = (SELECT actionID FROM dbo.Events WHERE eventID = @eventID)

		GROUP BY
		a.actionConcurrency
	END

	SELECT @canStart
END
