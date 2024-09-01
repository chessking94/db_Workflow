CREATE FUNCTION [dbo].[scheduleNextRunTime]
(
	@scheduleID INT
)

RETURNS DATETIME

AS

BEGIN
	DECLARE @nextDateTime DATETIME
    DECLARE @scheduleActive BIT
    DECLARE @scheduleStartDate DATE
    DECLARE @scheduleEndDate DATE
    DECLARE @scheduleRunTime TIME(0)
    DECLARE @recurrenceID TINYINT
    DECLARE @recurrenceInterval TINYINT
    DECLARE @recurrenceName VARCHAR(8)
    
    --populate details to variables
    SELECT
    @scheduleActive = s.scheduleActive,
    @scheduleStartDate = s.scheduleStartDate,
    @scheduleEndDate = s.scheduleEndDate,
    @scheduleRunTime = s.scheduleRunTime,
    @recurrenceName = r.recurrenceName,
    @recurrenceInterval = s.recurrenceInterval

    FROM dbo.Schedules s
    LEFT JOIN dbo.Recurrences r ON
        s.recurrenceID = r.recurrenceID

    WHERE s.scheduleID = @scheduleID

    IF @scheduleActive = 0 RETURN NULL
    IF ISNULL(@scheduleEndDate, CONVERT(DATE, GETDATE())) < CONVERT(DATE, GETDATE()) RETURN NULL
    IF @recurrenceName = 'One-Time' RETURN NULL

    --reset @scheduleStartDate to the base datetime *yesterday*, to eliminate excessive iterations of this if scheduleStartDate were 3 years ago (for example)
    IF DATEDIFF(DAY, @scheduleStartDate, GETDATE()) > 0
    BEGIN
        SET @scheduleStartDate = CONVERT(DATE, GETDATE() - 1)
    END
    SET @nextDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @scheduleStartDate), CAST(@scheduleRunTime AS DATETIME))  --set base nextDateTime

    --calculate the next run time based on recurrence pattern
    IF @recurrenceName = 'Minutely'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(MINUTE, @recurrenceInterval, @nextDateTime)
        END
    END

    ELSE IF @recurrenceName = 'Hourly'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(HOUR, @recurrenceInterval, @nextDateTime)
        END
    END

    ELSE IF @recurrenceName = 'Daily'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(DAY, @recurrenceInterval, @nextDateTime)
        END
    END

    ELSE IF @recurrenceName = 'Weekly'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(WEEK, @recurrenceInterval, @nextDateTime)
        END
    END

    ELSE IF @recurrenceName = 'Monthly'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(MONTH, @recurrenceInterval, @nextDateTime)
        END
    END

    ELSE IF @recurrenceName = 'Yearly'
    BEGIN
        WHILE @nextDateTime <= GETDATE()
        BEGIN
            SET @nextDateTime = DATEADD(YEAR, @recurrenceInterval, @nextDateTime)
        END
    END
    
    --ensure that the next run time not after the end date
    IF (@scheduleEndDate IS NOT NULL) AND (@nextDateTime > DATEADD(DAY, DATEDIFF(DAY, 0, @scheduleEndDate), CAST(@scheduleRunTime AS DATETIME)))
    BEGIN
        RETURN NULL
    END

    RETURN @nextDateTime
END
