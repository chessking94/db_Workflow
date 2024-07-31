CREATE PROCEDURE [dbo].[disableAction] (
	@actionName VARCHAR(20)
)

AS

UPDATE dbo.Actions
SET actionActive = 0
WHERE actionName = @actionName
