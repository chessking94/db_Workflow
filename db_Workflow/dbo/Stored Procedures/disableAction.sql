CREATE PROCEDURE [dbo].[disableAction] (@actionName AS VARCHAR(20))

AS

UPDATE dbo.Actions
SET actionActive = 0
WHERE actionName = @actionName
