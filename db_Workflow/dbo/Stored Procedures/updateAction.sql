CREATE PROCEDURE [dbo].[updateAction] (
	@actionID INT,
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

	--get old values
	DECLARE @oldName VARCHAR(50)
	DECLARE @oldDescription VARCHAR(100)
	DECLARE @oldActive BIT
	DECLARE @oldRequireParameters BIT
	DECLARE @oldConcurrency TINYINT
	DECLARE @oldLogOutput BIT
	DECLARE @oldApplicationName VARCHAR(50)

	SELECT
	@oldName = act.actionName,
	@oldDescription = act.actionDescription,
	@oldActive = act.actionActive,
	@oldRequireParameters = act.actionRequireParameters,
	@oldConcurrency = act.actionConcurrency,
	@oldLogOutput = act.actionLogOutput,
	@oldApplicationName = app.applicationName

	FROM dbo.Actions act
	LEFT JOIN dbo.Applications app ON
		act.applicationID = app.applicationID

	WHERE act.actionID = @actionID

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
		IF @actionLogOutput <> @oldLogOutput SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@applicationName, '') <> ISNULL(@oldApplicationName, '') SET @canUpdate = 1
	END

	IF @canUpdate = 1
	BEGIN
		UPDATE dbo.Actions
		SET actionName = @actionName,
			actionDescription = @actionDescription,
			actionActive = @actionActive,
			actionRequireParameters = @actionRequireParameters,
			actionConcurrency = @actionConcurrency,
			actionLogOutput = @actionLogOutput,
			applicationID = (SELECT applicationID FROM dbo.Applications WHERE applicationName = @applicationName)
		WHERE actionID = @actionID

		RETURN 0
	END

	ELSE

	BEGIN
		--no values changed
		RETURN 1
	END
END

