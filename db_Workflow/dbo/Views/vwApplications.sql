CREATE VIEW [dbo].[vwApplications]

AS

SELECT
applicationID,
applicationName,
applicationDescription,
applicationFilename,
applicationDefaultParameter,
applicationActive

FROM dbo.Applications
