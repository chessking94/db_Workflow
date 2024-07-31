CREATE PROCEDURE [dbo].[enableAction] (
	@actionName VARCHAR(20)
)

AS

UPDATE dbo.Actions
SET actionActive = 1
WHERE actionName = @actionName
