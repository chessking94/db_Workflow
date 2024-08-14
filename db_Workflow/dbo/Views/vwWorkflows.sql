CREATE VIEW [dbo].[vwWorkflows]

AS

SELECT
workflowID,
workflowName,
workflowDescription,
workflowActive

FROM dbo.Workflows
