CREATE PROCEDURE [dbo].[createWorkflow] (
	@workflowName VARCHAR(50),
	@workflowDescription VARCHAR(100),
	@workflowActive BIT
)

AS

BEGIN
	--convert empty strings to nulls
	SET @workflowName = NULLIF(@workflowName, '')
	SET @workflowDescription = NULLIF(@workflowDescription, '')

	IF @workflowName IS NULL RETURN -1  --null name
	IF @workflowDescription IS NULL RETURN -2  --null description
	--do not need to validate Active, is a bit data type

	INSERT INTO dbo.Workflows (workflowName, workflowDescription, workflowActive)
	VALUES (@workflowName, @workflowDescription, @workflowActive)

	RETURN @@IDENTITY
END
