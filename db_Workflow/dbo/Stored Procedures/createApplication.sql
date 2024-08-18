CREATE PROCEDURE [dbo].[createApplication] (
	@applicationName VARCHAR(50),
	@applicationDescription VARCHAR(100),
	@applicationFilename VARCHAR(250),
	@applicationActive BIT,
	@applicationDefaultParameter VARCHAR(250) = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @applicationName = NULLIF(@applicationName, '')
	SET @applicationDescription = NULLIF(@applicationDescription, '')
	SET @applicationFilename = NULLIF(@applicationFilename, '')
	SET @applicationDefaultParameter = NULLIF(@applicationDefaultParameter, '')

	IF @applicationName IS NULL RETURN -1  --null name
	IF @applicationDescription IS NULL RETURN -2  --null description
	IF @applicationFilename IS NULL RETURN -3  --null filename
	--do not need to validate applicationActive, required parameter and is a bit data type

	INSERT INTO dbo.Applications (applicationName, applicationDescription, applicationFilename, applicationActive, applicationDefaultParameter)
	VALUES (@applicationName, @applicationDescription, @applicationFilename, @applicationActive, @applicationDefaultParameter)

	RETURN @@IDENTITY
END

