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
    DECLARE @recurrenceName VARCHAR(8)
    DECLARE @recurrenceInterval TINYINT

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

    --adjust @scheduleStartDate to avoid excessive iterations
    IF @recurrenceName = 'Minutely'
        SET @scheduleStartDate = DATEADD(MINUTE, -(@recurrenceInterval * DATEDIFF(MINUTE, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))
    ELSE IF @recurrenceName = 'Hourly'
        SET @scheduleStartDate = DATEADD(HOUR, -(@recurrenceInterval * DATEDIFF(HOUR, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))
    ELSE IF @recurrenceName = 'Daily'
        SET @scheduleStartDate = DATEADD(DAY, -(@recurrenceInterval * DATEDIFF(DAY, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))
    ELSE IF @recurrenceName = 'Weekly'
        SET @scheduleStartDate = DATEADD(WEEK, -(@recurrenceInterval * DATEDIFF(WEEK, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))
    ELSE IF @recurrenceName = 'Monthly'
        SET @scheduleStartDate = DATEADD(MONTH, -(@recurrenceInterval * DATEDIFF(MONTH, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))
    ELSE IF @recurrenceName = 'Yearly'
        SET @scheduleStartDate = DATEADD(YEAR, -(@recurrenceInterval * DATEDIFF(YEAR, @scheduleStartDate, GETDATE()) / @recurrenceInterval), CAST(@scheduleStartDate AS DATETIME))

    --set initial @nextDateTime to adjusted @scheduleStartDate at @scheduleRunTime
    SET @nextDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @scheduleStartDate), CAST(@scheduleRunTime AS DATETIME))

    --calculate the next run time based on recurrence pattern
    WHILE @nextDateTime <= GETDATE()
    BEGIN
        IF @recurrenceName = 'Minutely'
            SET @nextDateTime = DATEADD(MINUTE, @recurrenceInterval, @nextDateTime)
        ELSE IF @recurrenceName = 'Hourly'
            SET @nextDateTime = DATEADD(HOUR, @recurrenceInterval, @nextDateTime)
        ELSE IF @recurrenceName = 'Daily'
            SET @nextDateTime = DATEADD(DAY, @recurrenceInterval, @nextDateTime)
        ELSE IF @recurrenceName = 'Weekly'
            SET @nextDateTime = DATEADD(WEEK, @recurrenceInterval, @nextDateTime)
        ELSE IF @recurrenceName = 'Monthly'
            SET @nextDateTime = DATEADD(MONTH, @recurrenceInterval, @nextDateTime)
        ELSE IF @recurrenceName = 'Yearly'
            SET @nextDateTime = DATEADD(YEAR, @recurrenceInterval, @nextDateTime)
    END

    --ensure the next run time is not after the end date
    IF (@scheduleEndDate IS NOT NULL) AND (@nextDateTime > DATEADD(DAY, DATEDIFF(DAY, 0, @scheduleEndDate), CAST(@scheduleRunTime AS DATETIME)))
    BEGIN
        RETURN NULL
    END

    RETURN @nextDateTime
END
