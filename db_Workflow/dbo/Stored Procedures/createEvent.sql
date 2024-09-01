CREATE PROCEDURE [dbo].[createEvent] (
	@workflowName VARCHAR(50) = NULL,
	@actionName VARCHAR(50) = NULL,
	@eventParameters VARCHAR(250) = NULL,
	@eventStartDate DATETIME = NULL
)

AS

DECLARE @workflowID SMALLINT
DECLARE @actionID INT

SET @workflowName = NULLIF(@workflowName, '')
SET @actionName = NULLIF(@actionName, '')
SET @eventParameters = NULLIF(@eventParameters, '')

IF (@workflowName IS NULL AND @actionName IS NULL) RETURN -1  --no workflow or action name passed

IF @workflowName IS NOT NULL
BEGIN
	SELECT @workflowID = workflowID FROM dbo.Workflows WHERE workflowName = @workflowName
	IF @workflowID IS NOT NULL
	BEGIN
		IF (SELECT COUNT(stepNumber) FROM dbo.WorkflowActions WHERE workflowID = @workflowID) = 0 RETURN -2  --no actions set up for this workflow
		IF (SELECT COUNT(e.eventID) FROM dbo.Events e JOIN dbo.EventStatuses es ON e.eventStatusID = es.eventStatusID WHERE workflowID = @workflowID AND es.isTerminal <> 1) > 0 RETURN -3  --active events for this workflow

		IF @eventStartDate IS NULL
		BEGIN
			INSERT INTO dbo.Events (workflowID, stepNumber, actionID, eventParameters)
			SELECT workflowID, stepNumber, actionID, eventParameters FROM dbo.WorkflowActions WHERE workflowID = @workflowID ORDER BY stepNumber
		END

		ELSE

		BEGIN
			INSERT INTO dbo.Events (workflowID, stepNumber, actionID, eventParameters, eventStartDate)
			SELECT workflowID, stepNumber, actionID, eventParameters, @eventStartDate FROM dbo.WorkflowActions WHERE workflowID = @workflowID ORDER BY stepNumber
		END

		RETURN @@ROWCOUNT  --return number of actions instead of last ID
	END

	ELSE

	BEGIN
		--invalid workflow name
		RETURN -4
	END
END

ELSE

BEGIN
	SELECT @actionID = actionID FROM dbo.Actions WHERE actionName = @actionName
	IF @actionID IS NOT NULL
	BEGIN
		IF @eventStartDate IS NULL
		BEGIN
			INSERT INTO dbo.Events (actionID, eventParameters)
			SELECT @actionID, @eventParameters
		END

		ELSE

		BEGIN
			INSERT INTO dbo.Events (actionID, eventParameters, eventStartDate)
			SELECT @actionID, @eventParameters, @eventStartDate
		END

		RETURN @@IDENTITY
	END

	ELSE

	BEGIN
		--invalid action name
		RETURN -5
	END
END
