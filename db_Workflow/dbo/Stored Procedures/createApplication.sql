CREATE PROCEDURE [dbo].[createApplication] (
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

	IF @applicationName IS NULL RETURN -1  --null name
	IF @applicationDescription IS NULL RETURN -2  --null description
	IF @applicationFilename IS NULL RETURN -3  --null filename
	--do not need to validate applicationActive, required parameter and is a bit data type
	IF @applicationType IS NOT NULL
	BEGIN
		IF (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationType = @applicationType) IS NULL RETURN -4  --application type does not exist
	END

	DECLARE @applicationTypeID SMALLINT = (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationType = @applicationType)

	INSERT INTO dbo.Applications (applicationName, applicationDescription, applicationFilename, applicationActive, applicationDefaultParameter, applicationTypeID)
	VALUES (@applicationName, @applicationDescription, @applicationFilename, @applicationActive, @applicationDefaultParameter, @applicationTypeID)

	RETURN @@IDENTITY
END

