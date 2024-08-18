CREATE VIEW [dbo].[vwActions]

AS

SELECT
actionID,
actionName,
actionDescription,
actionActive,
actionCreateDate,
actionRequireParameters,
actionConcurrency,
applicationID

FROM dbo.Actions
