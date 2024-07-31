CREATE PROCEDURE [dbo].[enableApplication] (
	@applicationName VARCHAR(20)
)

AS

UPDATE dbo.Applications
SET applicationActive = 1
WHERE applicationName = @applicationName
