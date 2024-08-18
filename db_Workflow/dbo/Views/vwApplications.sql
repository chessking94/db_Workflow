CREATE VIEW [dbo].[vwApplications]

AS

SELECT
applicationID,
applicationName,
applicationDescription,
applicationFilename,
applicationDefaultParameter,
applicationActive,
applicationCreateDate

FROM dbo.Applications
