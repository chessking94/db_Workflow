CREATE PROCEDURE [dbo].[createEvent] (
	@workflowID SMALLINT = NULL,
	@stepNumber TINYINT = NULL,
	@actionName VARCHAR(50) = NULL,
	@eventParameters VARCHAR(250) = NULL,
	@eventStartDate DATETIME = NULL
)

AS

DECLARE @errmsg NVARCHAR(128)
DECLARE @actionID INT

IF (@workflowID IS NOT NULL OR @stepNumber IS NOT NULL)
BEGIN
	--if workflow info is provided, override the provided actionName with what is associated with the workflow step
	SET @actionID = (SELECT actionID FROM dbo.WorkflowActions WHERE workflowID = @workflowID AND stepNumber = @stepNumber)
	IF @actionID IS NOT NULL
	BEGIN
		SET @actionName = @actionID
	END

	ELSE

	BEGIN
		SET @errmsg = 'Invalid workflow/step number combination!'
	END
END

IF @errmsg IS NULL
BEGIN
	IF ISNUMERIC(@actionName) = 1
	BEGIN
		IF EXISTS (SELECT actionID FROM dbo.Actions WHERE actionID = @actionName)
		BEGIN
			IF @eventStartDate IS NULL
			BEGIN
				INSERT INTO dbo.Events (actionID, eventParameters)
				SELECT @actionName, @eventParameters
			END

			ELSE

			BEGIN
				INSERT INTO dbo.Events (actionID, eventParameters, eventStartDate)
				SELECT @actionName, @eventParameters, @eventStartDate
			END
		END
	END

	ELSE

	BEGIN
		SET @actionID = (SELECT actionID FROM dbo.Actions WHERE actionName = @actionName)
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
		END

		ELSE

		BEGIN
			SET @errmsg = 'actionName parameter not a key or action name!'
		END
	END
END

IF @errmsg IS NOT NULL
BEGIN
	RAISERROR(@errmsg, 16, 1)
END
