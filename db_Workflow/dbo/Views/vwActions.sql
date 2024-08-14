CREATE VIEW [dbo].[vwActions]

AS

SELECT
actionID,
actionName,
actionDescription,
actionActive,
actionRequireParameters,
actionConcurrency,
applicationID

FROM dbo.Actions
