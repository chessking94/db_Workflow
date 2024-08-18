CREATE PROCEDURE [dbo].[insertWorkflowAction] (
	@workflowName VARCHAR(50),
	@stepNumber INT
)

AS

BEGIN
	INSERT INTO stage_WorkflowActions (workflowID, stepNumber)
	SELECT w.workflowID, @stepNumber FROM dbo.Workflows w WHERE w.workflowName = @workflowName

	RETURN @@IDENTITY
END
