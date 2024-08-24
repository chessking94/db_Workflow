CREATE PROCEDURE [dbo].[createAction] (
	@actionName VARCHAR(50),
	@actionDescription VARCHAR(100),
	@actionActive BIT,
	@actionRequireParameters BIT,
	@actionConcurrency TINYINT,
	@actionLogOutput BIT,
	@applicationID INT = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @actionName = NULLIF(@actionName, '')
	SET @actionDescription = NULLIF(@actionDescription, '')

	IF @actionName IS NULL RETURN -1  --null name
	IF @actionDescription IS NULL RETURN -2  --null description
	--do not need to validate Active, RequireParameters, or Concurrency, required parameters and is a bit data type
	IF @applicationID IS NOT NULL
	BEGIN
		IF (SELECT applicationID FROM dbo.Applications WHERE applicationID = @applicationID) IS NULL RETURN -3  --application does not exist
	END

	INSERT INTO dbo.Actions (actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, actionLogOutput, applicationID)
	VALUES (@actionName, @actionDescription, @actionActive, @actionRequireParameters, @actionConcurrency, @actionLogOutput, @applicationID)

	RETURN @@IDENTITY
END
