CREATE PROCEDURE [dbo].[createAction] (
	@actionName VARCHAR(50),
	@actionDescription VARCHAR(100),
	@actionActive BIT,
	@actionRequireParameters BIT,
	@actionConcurrency TINYINT,
	@actionLogOutput BIT,
	@applicationName VARCHAR(50) = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @actionName = NULLIF(@actionName, '')
	SET @actionDescription = NULLIF(@actionDescription, '')
	SET @applicationName = NULLIF(@applicationName, '')

	IF @actionName IS NULL RETURN -1  --null name
	IF @actionDescription IS NULL RETURN -2  --null description
	--do not need to validate Active, RequireParameters, or Concurrency, required parameters and is a bit data type
	IF @applicationName IS NOT NULL
	BEGIN
		IF (SELECT applicationName FROM dbo.Applications WHERE applicationName = @applicationName) IS NULL RETURN -3  --application does not exist
	END

	DECLARE @applicationID INT = (SELECT applicationID FROM dbo.Applications WHERE applicationName = @applicationName)

	INSERT INTO dbo.Actions (actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, actionLogOutput, applicationID)
	VALUES (@actionName, @actionDescription, @actionActive, @actionRequireParameters, @actionConcurrency, @actionLogOutput, @applicationID)

	RETURN @@IDENTITY
END
