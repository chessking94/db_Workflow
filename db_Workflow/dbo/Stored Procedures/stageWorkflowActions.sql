CREATE PROCEDURE [dbo].[stageWorkflowActions] (
	@workflowName VARCHAR(20)
)

AS

BEGIN
	DELETE stg
	FROM dbo.stage_WorkflowActions stg
	JOIN dbo.Workflows wf ON
		stg.workflowID = wf.workflowID
	WHERE wf.workflowName = @workflowName

	INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
	SELECT
	wa.workflowID,
	wa.stepNumber,
	wa.actionID,
	wa.eventParameters,
	wa.continueAfterError

	FROM dbo.WorkflowActions wa
	JOIN dbo.Workflows wf ON
		wa.workflowID = wf.workflowID
	WHERE wf.workflowName = @workflowName
END
