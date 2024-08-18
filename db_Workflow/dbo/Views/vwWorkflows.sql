CREATE VIEW [dbo].[vwWorkflows]

AS

SELECT
workflowID,
workflowName,
workflowDescription,
workflowActive,
workflowCreateDate

FROM dbo.Workflows
