CREATE PROCEDURE [dbo].[canStartEvent] (
	@eventID INT
)

AS

BEGIN
	--validation to determine if the event should be cancelled
	DECLARE @foundError BIT = 0
	DECLARE @eventStatusID SMALLINT
	DECLARE @eventNote VARCHAR(MAX)

	----is workflow active?
	IF @foundError = 0
	BEGIN
		SELECT
		@foundError = 1 - CAST(ISNULL(w.workflowActive, 1) AS TINYINT)

		FROM dbo.Events e
		JOIN dbo.Workflows w ON
			e.workflowID = w.workflowID
	
		WHERE e.eventID = @eventID

		IF @foundError = 1
		BEGIN
			SET @eventStatusID = 0
			SET @eventNote = 'Workflow inactive'
		END
	END

	----is application active?
	IF @foundError = 0
	BEGIN
		SELECT
		@foundError = 1 - CAST(ISNULL(app.applicationActive, 1) AS TINYINT)

		FROM dbo.Events e
		JOIN dbo.Actions a ON
			e.actionID = a.actionID
		LEFT JOIN dbo.Applications app ON
			a.applicationID = app.applicationID
	
		WHERE e.eventID = @eventID

		IF @foundError = 1
		BEGIN
			SET @eventStatusID = 0
			SET @eventNote = 'Application inactive'
		END
	END

	----is action active?
	IF @foundError = 0
	BEGIN
		SELECT
		@foundError = 1 - CAST(a.actionActive AS TINYINT)

		FROM dbo.Events e
		JOIN dbo.Actions a ON
			e.actionID = a.actionID

		WHERE e.eventID = @eventID

		IF @foundError = 1
		BEGIN
			SET @eventStatusID = 0
			SET @eventNote = 'Action inactive'
		END
	END

	----does an action requiring parameters have parameters?
	IF @foundError = 0
	BEGIN
		SELECT
		@foundError = (CASE WHEN a.actionRequireParameters = 1 AND NULLIF(e.eventParameters, '') IS NULL THEN 1 ELSE 0 END)

		FROM dbo.Events e
		JOIN dbo.Actions a ON
			e.actionID = a.actionID

		WHERE e.eventID = @eventID

		IF @foundError = 1
		BEGIN
			SET @eventStatusID = -1
			SET @eventNote = 'Action missing parameters'
		END
	END

	IF @foundError = 1
	BEGIN
		EXEC updateEventStatus @eventID = @eventID, @eventStatus = @eventStatusID, @eventNote = @eventNote
		SELECT 0
	END
	ELSE
	BEGIN
		--not cancelling, validate now if the event can be started
		----is the event in a startable status?
		DECLARE @canStart BIT = 1
		IF @canStart = 1
		BEGIN
			SELECT
			@canStart = (CASE WHEN (es.inProgress = 1 OR es.isTerminal = 1) THEN 0 ELSE 1 END)

			FROM dbo.Events e
			JOIN dbo.EventStatuses es ON
				e.eventStatusID = es.eventStatusID

			WHERE e.eventID = @eventID
		END

		----if the event is for a workflow, ensure prerequisite step is complete
		DECLARE @workflowID SMALLINT = (SELECT workflowID FROM dbo.Events WHERE eventID = @eventID)
		IF (@canStart = 1 AND @workflowID IS NOT NULL)
		BEGIN
			SELECT TOP(1)
			@canStart = (
				CASE
					WHEN es.inProgress = 1 THEN 0
					WHEN es.eventStatusID = 2 THEN 0
					WHEN es.eventStatusID = -1 AND wa.continueAfterError = 0 THEN 0
					ELSE 1
				END
			)

			FROM dbo.Events e
			JOIN dbo.EventStatuses es ON
				e.eventStatusID = es.eventStatusID
			JOIN dbo.WorkflowActions wa ON
				e.workflowID = wa.workflowID
				AND e.stepNumber = wa.stepNumber

			WHERE e.workflowID = @workflowID
			AND e.stepNumber = (SELECT stepNumber FROM dbo.Events WHERE eventID = @eventID) - 1

			ORDER BY e.eventID DESC

			IF @canStart IS NULL SET @canStart = 1  --this should only hit if the step being checked is step 1 (meaning step - 1 = 0, so no records in above query)
		END

		----are too many instances of the action already running?
		IF @canStart >= 1
		BEGIN
			SELECT
			CASE
				WHEN SUM(CAST(es.inProgress AS TINYINT)) < a.actionConcurrency THEN 1
				ELSE 0
			END AS canStartEvent

			FROM dbo.Events e
			JOIN dbo.EventStatuses es ON
				e.eventStatusID = es.eventStatusID
			JOIN dbo.Actions a ON
				e.actionID = a.actionID

			WHERE e.actionID = (SELECT actionID FROM dbo.Events WHERE eventID = @eventID)

			GROUP BY
			a.actionConcurrency
		END

		SELECT @canStart
	END
END
