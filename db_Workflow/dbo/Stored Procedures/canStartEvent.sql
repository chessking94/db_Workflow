CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

DECLARE @cancelEvent BIT = 0
DECLARE @cancelEventReason VARCHAR(MAX)

--is action active?
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

--is application active?
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

IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = (CASE WHEN (es.inProgress = 1 OR es.isTerminal = 1) THEN 1 ELSE 0 END)

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID

	WHERE e.eventID = @eventID

	IF @cancelEvent = 1
	BEGIN
		SET @cancelEvent = 0  --do not actually want to cancel this situation, the task is already running/has completed
		SET @cancelEventReason = 'Invalid current status'
	END
END

--return 1 if an event can be started, 0 if it cannot
IF @cancelEvent = 1
BEGIN
	EXEC updateEventStatus @eventID = @eventID, @eventStatus = 0, @eventError = @cancelEventReason
	SELECT 0
END
ELSE
BEGIN
	SELECT
	CASE
		WHEN @cancelEvent IS NOT NULL THEN 0  --populating this is a catch-all to do nothing
		WHEN COUNT(e.eventID) < a.actionConcurrency THEN 1
		ELSE 0
	END AS canStartEvent

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID
	JOIN dbo.Actions a ON
		e.actionID = a.actionID

	WHERE es.inProgress = 1
	AND e.actionID = (SELECT actionID FROM dbo.Events WHERE eventID = @eventID)

	GROUP BY
	a.actionConcurrency
END
