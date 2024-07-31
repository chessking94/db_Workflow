CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

--return 1 if an event can be started, 0 if it cannot
SELECT
CASE
	WHEN COUNT(e.EventID) < a.actionConcurrency THEN 1
	ELSE 0
END AS canStartEvent

FROM dbo.Events e
JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID
JOIN dbo.Actions a ON e.actionID = a.actionID

WHERE es.isTerminal = 0
AND e.eventStatusID <> 2  --do not count Pending, these have not started yet
AND e.actionID = (SELECT actionID FROM dbo.Events WHERE eventID = @eventID)
