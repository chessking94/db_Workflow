CREATE PROCEDURE [dbo].[createWorkflow] (
	@workflowName VARCHAR(50),
	@workflowDescription VARCHAR(100),
	@workflowActive BIT,
	@scheduleName VARCHAR(50) = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @workflowName = NULLIF(@workflowName, '')
	SET @workflowDescription = NULLIF(@workflowDescription, '')
	SET @scheduleName = NULLIF(@scheduleName, '')

	IF @workflowName IS NULL RETURN -1  --null name
	IF @workflowDescription IS NULL RETURN -2  --null description
	--do not need to validate Active, is a bit data type

	DECLARE @scheduleID INT = (SELECT scheduleID FROM dbo.Schedules WHERE scheduleName = @scheduleName)

	INSERT INTO dbo.Workflows (workflowName, workflowDescription, workflowActive, scheduleID)
	VALUES (@workflowName, @workflowDescription, @workflowActive, @scheduleID)

	RETURN @@IDENTITY
END
