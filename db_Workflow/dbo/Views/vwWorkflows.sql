CREATE VIEW [dbo].[vwWorkflows]

AS

SELECT
workflowID,
workflowName,
workflowDescription,
workflowActive,
workflowCreateDate,
s.scheduleName

FROM dbo.Workflows w
LEFT JOIN dbo.Schedules s ON
	w.scheduleID = s.scheduleID
