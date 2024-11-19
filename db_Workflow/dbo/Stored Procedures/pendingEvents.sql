CREATE PROCEDURE [dbo].[pendingEvents]

AS

BEGIN
	SELECT
	e.eventID,
	a.actionID,
	app.applicationFilename,
	app.applicationDefaultParameter,
	e.eventParameters,
	a.actionLogOutput,
	t.applicationType

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID
	JOIN dbo.Actions a ON
		e.actionID = a.actionID
	LEFT JOIN dbo.Applications app ON
		a.applicationID = app.applicationID
	LEFT JOIN dbo.ApplicationTypes t ON
		app.applicationTypeID = t.applicationTypeID

	WHERE es.inProgress = 0
	AND es.isTerminal = 0
	AND e.eventStartDate <= GETDATE()
END
