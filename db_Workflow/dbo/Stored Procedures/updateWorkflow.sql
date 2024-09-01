CREATE PROCEDURE [dbo].[updateWorkflow] (
	@workflowID SMALLINT,
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

	--get old values
	DECLARE @oldName VARCHAR(50)
	DECLARE @oldDescription VARCHAR(100)
	DECLARE @oldActive BIT
	DECLARE @oldScheduleName VARCHAR(50)

	SELECT
	@oldName = w.workflowName,
	@oldDescription = w.workflowDescription,
	@oldActive = w.workflowActive,
	@oldScheduleName = s.scheduleName

	FROM dbo.Workflows w
	LEFT JOIN dbo.Schedules s ON
		w.scheduleID = s.scheduleID

	WHERE w.workflowID = @workflowID

	--confirm there was an update
	DECLARE @canUpdate BIT = 0

	IF @canUpdate = 0
	BEGIN
		IF @workflowName <> @oldName SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @workflowDescription <> @oldDescription SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @workflowActive <> @oldActive SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@scheduleName, '') <> ISNULL(@oldScheduleName, '') SET @canUpdate = 1
	END

	IF @canUpdate = 1
	BEGIN
		UPDATE dbo.Workflows
		SET workflowName = @workflowName,
			workflowDescription = @workflowDescription,
			workflowActive = @workflowActive,
			scheduleID = (SELECT scheduleID FROM dbo.Schedules WHERE scheduleName = @scheduleName)
		WHERE workflowID = @workflowID

		RETURN 0
	END

	ELSE

	BEGIN
		--no values changed
		RETURN 1
	END
END

