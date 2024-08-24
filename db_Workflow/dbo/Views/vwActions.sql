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
actionLogOutput,
applicationID

FROM dbo.Actions
