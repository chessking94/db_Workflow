CREATE VIEW [dbo].[vwSchedules]

AS

SELECT
s.scheduleID,
s.scheduleName,
s.scheduleCreateDate,
s.scheduleActive,
s.scheduleStartDate,
s.scheduleEndDate,
s.scheduleRunTime,
r.recurrenceName,
s.recurrenceInterval

FROM dbo.Schedules s
LEFT JOIN dbo.Recurrences r ON
	s.recurrenceID = r.recurrenceID
