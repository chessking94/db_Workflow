CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

DECLARE @cancelEvent bit = 0

--is action active?
IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = 1 - CAST(a.actionActive AS tinyint)

	FROM dbo.Events e
	JOIN dbo.Actions a ON
		e.actionID = a.actionID

	WHERE e.eventID = @eventID
END

--is application active?
IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = 1 - CAST(ISNULL(app.applicationActive, 1) AS tinyint)

	FROM dbo.Events e
	JOIN dbo.Actions a ON
		e.actionID = a.actionID
	LEFT JOIN dbo.Applications app ON
		a.applicationID = app.applicationID
	
	WHERE e.eventID = @eventID
END

IF @cancelEvent = 0
BEGIN
	SELECT
	@cancelEvent = (CASE WHEN (es.inProgress = 1 OR es.isTerminal = 1) THEN 1 ELSE 0 END)

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID

	WHERE e.eventID = @eventID
END

--return 1 if an event can be started, 0 if it cannot
IF @cancelEvent = 1
BEGIN
	UPDATE dbo.Events SET eventStatusID = 0 WHERE eventID = @eventID
	SELECT 0
END
ELSE
BEGIN
	SELECT
	CASE
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
