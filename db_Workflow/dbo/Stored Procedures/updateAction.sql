CREATE PROCEDURE [dbo].[updateAction] (
	@actionID INT,
	@actionName VARCHAR(50),
	@actionDescription VARCHAR(100),
	@actionActive BIT,
	@actionRequireParameters BIT,
	@actionConcurrency TINYINT,
	@applicationID INT = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @actionName = NULLIF(@actionName, '')
	SET @actionDescription = NULLIF(@actionDescription, '')

	--get old values
	DECLARE @oldName VARCHAR(50)
	DECLARE @oldDescription VARCHAR(100)
	DECLARE @oldActive BIT
	DECLARE @oldRequireParameters BIT
	DECLARE @oldConcurrency TINYINT
	DECLARE @oldApplicationID INT

	SELECT
	@oldName = actionName,
	@oldDescription = actionDescription,
	@oldActive = actionActive,
	@oldRequireParameters = actionRequireParameters,
	@oldConcurrency = actionConcurrency,
	@oldApplicationID = applicationID

	FROM dbo.Actions

	WHERE actionID = @actionID

	--confirm there was an update
	DECLARE @canUpdate BIT = 0

	IF @canUpdate = 0
	BEGIN
		IF @actionName <> @oldName SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @actionDescription <> @oldDescription SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @actionActive <> @oldActive SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @actionRequireParameters <> @oldRequireParameters SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @actionConcurrency <> @oldConcurrency SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@applicationID, -1) <> ISNULL(@oldApplicationID, -1) SET @canUpdate = 1
	END

	IF @canUpdate = 1
	BEGIN
		UPDATE dbo.Actions
		SET actionName = @actionName,
			actionDescription = @actionDescription,
			actionActive = @actionActive,
			actionRequireParameters = @actionRequireParameters,
			actionConcurrency = @actionConcurrency,
			applicationID = @applicationID
		WHERE actionID = @actionID

		RETURN 0
	END

	ELSE

	BEGIN
		--no values changed
		RETURN 1
	END
END

