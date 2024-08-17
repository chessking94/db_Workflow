CREATE PROCEDURE [dbo].[saveWorkflowAction] (
	@stagingKey INT,
	@stepNumber TINYINT,
	@actionName VARCHAR(20),
	@eventParameters VARCHAR(250),
	@continueAfterError BIT
)

AS

BEGIN
	--convert empty strings to nulls
	SET @eventParameters = NULLIF(@eventParameters, '')

	UPDATE dbo.stage_WorkflowActions
	SET stepNumber = @stepNumber,
		actionID = (SELECT actionID FROM dbo.Actions WHERE actionName = @actionName),
		eventParameters = @eventParameters,
		continueAfterError = @continueAfterError
	WHERE stagingKey = @stagingKey

	--recalculate the step numbers
	CREATE TABLE #workflowActions (orderValue INT IDENTITY(1,1), stagingKey INT, stepNumber TINYINT)

	DECLARE @workflowID INT
	SELECT @workflowID = workflowID FROM dbo.stage_WorkflowActions WHERE stagingKey = @stagingKey

	INSERT INTO #workflowActions (stagingKey, stepNumber)
	SELECT stagingKey, stepNumber FROM dbo.stage_WorkflowActions WHERE workflowID = @workflowID ORDER BY stepNumber, stagingKey

	DECLARE @tempstagingKey INT
	SET @tempstagingKey = (SELECT TOP 1 stagingKey FROM #workflowActions ORDER BY orderValue)
	WHILE @tempstagingKey IS NOT NULL
		BEGIN
		IF @tempstagingKey <> @stagingKey
		BEGIN
			IF @stepNumber <= (SELECT stepNumber FROM dbo.stage_WorkflowActions WHERE stagingKey = @tempstagingKey)
			BEGIN
				UPDATE dbo.stage_WorkflowActions
				SET stepNumber = stepNumber + 1
				WHERE stagingKey = @tempstagingKey
			END
		END
		DELETE FROM #workflowActions WHERE stagingKey = @tempstagingKey
		SET @tempstagingKey = (SELECT TOP 1 stagingKey FROM #workflowActions ORDER BY orderValue)
	END

	IF (OBJECT_ID('tempdb..#workflowActions') IS NOT NULL) DROP TABLE #workflowActions
END
