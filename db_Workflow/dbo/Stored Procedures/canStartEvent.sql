CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

--return 1 if an event can be started, 0 if it cannot
SELECT
CASE
	WHEN COUNT(e.eventID) < a.actionConcurrency THEN 1
	ELSE 0
END AS canStartEvent

FROM dbo.Events e
JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID
JOIN dbo.Actions a ON e.actionID = a.actionID

WHERE es.inProgress = 1
AND e.actionID = (SELECT actionID FROM dbo.Events WHERE eventID = @eventID)

GROUP BY
a.actionConcurrency
