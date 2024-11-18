CREATE VIEW [dbo].[vwApplications]

AS

SELECT
a.applicationID,
a.applicationName,
a.applicationDescription,
a.applicationFilename,
a.applicationDefaultParameter,
a.applicationActive,
a.applicationCreateDate,
typ.applicationType

FROM dbo.Applications a
JOIN dbo.ApplicationTypes typ ON
	a.applicationTypeID = typ.applicationTypeID
