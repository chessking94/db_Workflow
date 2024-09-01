CREATE VIEW [dbo].[vwActions]

AS

SELECT
act.actionID,
act.actionName,
act.actionDescription,
act.actionActive,
act.actionCreateDate,
act.actionRequireParameters,
act.actionConcurrency,
act.actionLogOutput,
app.applicationName

FROM dbo.Actions act
LEFT JOIN dbo.Applications app ON
	act.applicationID = app.applicationID

