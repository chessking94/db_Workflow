CREATE VIEW [dbo].[vwActiveEvents]

AS

SELECT
e.eventID,
app.applicationName,
w.workflowName,
wa.stepNumber,
a.actionName,
e.eventParameters,
es.eventStatus,
e.eventStatusDate,
e.eventStartDate

FROM dbo.Events e
JOIN dbo.EventStatuses es ON
	e.eventStatusID = es.eventStatusID
JOIN dbo.Actions a ON
	e.actionID = a.actionID
LEFT JOIN dbo.Applications app ON
	a.applicationID = app.applicationID
LEFT JOIN dbo.WorkflowActions wa ON
	e.workflowID = wa.workflowID
	AND e.stepNumber = wa.stepNumber
LEFT JOIN dbo.Workflows w ON
	wa.workflowID = w.workflowID

WHERE es.isTerminal = 0
