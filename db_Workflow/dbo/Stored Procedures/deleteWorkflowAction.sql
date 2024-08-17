CREATE PROCEDURE [dbo].[deleteWorkflowAction] (
	@stagingKey INT
)

AS

BEGIN
    DECLARE @workflowID INT
    SELECT @workflowID = workflowID FROM stage_WorkflowActions WHERE stagingKey = @stagingKey

	DELETE FROM stage_WorkflowActions WHERE stagingKey = @stagingKey;

    --recalculate step numbers to fill holes
	WITH newStepNumbers (stagingKey, newStepNumber)
    AS (
        SELECT
        stagingKey,
        ROW_NUMBER() OVER (PARTITION BY workflowID ORDER BY stepNumber) AS newStepNumber
        FROM dbo.stage_WorkflowActions
        WHERE workflowID = @workflowID
    )

    UPDATE stg
    SET stg.stepNumber = new.newStepNumber
    FROM dbo.stage_WorkflowActions stg
    JOIN newStepNumbers new ON stg.stagingKey = new.stagingKey
END
