CREATE PROCEDURE [dbo].[createSchedule] (
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

	IF @scheduleName IS NULL RETURN -1  --null name
	IF @recurrenceName IS NOT NULL
	BEGIN
		IF (SELECT recurrenceName FROM dbo.Recurrences WHERE recurrenceName = @recurrenceName) IS NULL RETURN -2  --recurrence does not exist
	END
	IF @recurrenceInterval IS NOT NULL
	BEGIN
		IF @recurrenceInterval >= 60 RETURN -3  --invalid interval value
	END

	DECLARE @recurrenceID TINYINT = (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceName = @recurrenceName)

	INSERT INTO dbo.Schedules(scheduleName, scheduleActive, scheduleStartDate, scheduleEndDate, scheduleRunTime, recurrenceID, recurrenceInterval)
	VALUES (@scheduleName, @scheduleActive, @scheduleStartDate, @scheduleEndDate, @scheduleRunTime, @recurrenceID, @recurrenceInterval)

	RETURN @@IDENTITY
END
