CREATE PROCEDURE [dbo].[createWorkflowActions] (
	@workflowName VARCHAR(20)
)

AS

--the idea is that creation of or updates to a workflow are defined in a staging table, then migrated to the live table
--assume validation has already occurred and the records in stage_WorkflowEvents are good

DECLARE @workflowID SMALLINT
SELECT @workflowID = workflowID FROM dbo.Workflows WHERE workflowName = @workflowName

--do not allow this to continue if there are non-terminal events for a workflow.
DECLARE @activeEvents INT

SELECT
@activeEvents = COUNT(1)

FROM dbo.Events e
JOIN dbo.EventStatuses es ON
	e.eventStatusID = es.eventStatusID

WHERE e.workflowID = @workflowID
AND es.isTerminal = 0

IF @activeEvents > 0
BEGIN
	RAISERROR('Unable to update workflow, non-terminal events exist', 1, 1)
	RETURN -1
END


DELETE FROM dbo.WorkflowActions WHERE workflowID = @workflowID

INSERT INTO dbo.WorkflowActions (
	workflowID,
	stepNumber,
	actionID,
	eventParameters,
	continueAfterError
)

SELECT
workflowID,
stepNumber,
actionID,
eventParameters,
continueAfterError

FROM dbo.stage_WorkflowActions

WHERE workflowID = @workflowID

RETURN 0
