CREATE PROCEDURE [dbo].[disableApplication] (@applicationName AS VARCHAR(20))

AS

UPDATE dbo.Applications
SET applicationActive = 0
WHERE applicationName = @applicationName
