CREATE PROCEDURE [dbo].[updateSchedule] (
	@scheduleID INT,
	@scheduleName VARCHAR(50),
	@scheduleActive BIT,
	@scheduleStartDate DATE,
	@scheduleEndDate DATE = NULL,
	@scheduleRunTime TIME(0),
	@recurrenceName VARCHAR(8) = NULL,
	@recurrenceInterval TINYINT = NULL
)

AS

BEGIN
	--convert empty strings to nulls
	SET @scheduleName = NULLIF(@scheduleName, '')
	SET @recurrenceName = NULLIF(@recurrenceName, '')

	--get old values
	DECLARE @oldName VARCHAR(50)
	DECLARE @oldActive BIT
	DECLARE @oldStartDate DATE
	DECLARE @oldEndDate DATE
	DECLARE @oldRunTime TIME(0)
	DECLARE @oldRecurrenceName VARCHAR(8)
	DECLARE @oldRecurrenceInterval TINYINT

	SELECT
	@oldName = s.scheduleName,
	@oldActive = s.scheduleActive,
	@oldStartDate = s.scheduleStartDate,
	@oldEndDate = s.scheduleEndDate,
	@oldRunTime = s.scheduleRunTime,
	@oldRecurrenceName = r.recurrenceName,
	@oldRecurrenceInterval = s.recurrenceInterval

	FROM dbo.Schedules s
	LEFT JOIN dbo.Recurrences r ON
		s.recurrenceID = r.recurrenceID

	WHERE s.scheduleID = @scheduleID

	--confirm there was an update
	DECLARE @canUpdate BIT = 0

	IF @canUpdate = 0
	BEGIN
		IF @scheduleName <> @oldName SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @scheduleActive <> @oldActive SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @scheduleStartDate <> @oldStartDate SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@scheduleEndDate, '1900-01-01') <> ISNULL(@oldEndDate, '1900-01-01') SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF @scheduleRunTime <> @oldRunTime SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@recurrenceName, '') <> ISNULL(@oldRecurrenceName, '') SET @canUpdate = 1
	END

	IF @canUpdate = 0
	BEGIN
		IF ISNULL(@recurrenceInterval, -1) <> ISNULL(@oldRecurrenceInterval, -1) SET @canUpdate = 1
	END

	IF @canUpdate = 1
	BEGIN
		UPDATE dbo.Schedules
		SET scheduleName = @scheduleName,
			scheduleActive = @scheduleActive,
			scheduleStartDate = @scheduleStartDate,
			scheduleEndDate = @scheduleEndDate,
			scheduleRunTime = @scheduleRunTime,
			recurrenceID = (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceName = @recurrenceName),
			recurrenceInterval = @recurrenceInterval
		WHERE scheduleID = @scheduleID

		RETURN 0
	END

	ELSE

	BEGIN
		--no values changed
		RETURN 1
	END
END

