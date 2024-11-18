CREATE PROCEDURE [dbo].[updateApplication] (
	@applicationID INT,
	@applicationName VARCHAR(50),
	@applicationDescription VARCHAR(100),
	@applicationFilename VARCHAR(250),
	@applicationActive BIT,
	@applicationDefaultParameter VARCHAR(250) = NULL,
	@applicationType VARCHAR(50)
)

AS

BEGIN
	--convert empty strings to nulls
	SET @applicationName = NULLIF(@applicationName, '')
	SET @applicationDescription = NULLIF(@applicationDescription, '')
	SET @applicationFilename = NULLIF(@applicationFilename, '')
	SET @applicationDefaultParameter = NULLIF(@applicationDefaultParameter, '')
	SET @applicationType = NULLIF(@applicationType, '')

	--get old values
	DECLARE @oldName VARCHAR(50)
	DECLARE @oldDescription VARCHAR(100)
	DECLARE @oldFilename VARCHAR(250)
	DECLARE @oldActive BIT
	DECLARE @oldDefaultParameter VARCHAR(250)
	DECLARE @oldType VARCHAR(50)

	SELECT
	@oldName = a.applicationName,
	@oldDescription = a.applicationDescription,
	@oldFilename = a.applicationFilename,
	@oldActive = a.applicationActive,
	@oldDefaultParameter = a.applicationDefaultParameter,
	@oldType = t.applicationType

	FROM dbo.Applications a
	JOIN dbo.ApplicationTypes t ON
		a.applicationTypeID = t.applicationTypeID

	WHERE a.applicationID = @applicationID

	--confirm there was an update
	DECLARE @canUpdate BIT = 0

	IF @canUpdate = 0
	BEGIN
		IF @applicationName <> @oldName SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @applicationDescription <> @oldDescription SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @applicationFilename <> @oldFilename SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @applicationActive <> @oldActive SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @applicationDefaultParameter <> @oldDefaultParameter SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @applicationType <> @oldType SET @canUpdate = 1
	END

	IF @canUpdate = 1
	BEGIN
		UPDATE dbo.Applications
		SET applicationName = @applicationName,
			applicationDescription = @applicationDescription,
			applicationFilename = @applicationFilename,
			applicationActive = @applicationActive,
			applicationDefaultParameter = @applicationDefaultParameter,
			applicationTypeID = (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationType = @applicationType)
		WHERE applicationID = @applicationID

		RETURN 0
	END

	ELSE

	BEGIN
		--no values changed
		RETURN 1
	END
END

