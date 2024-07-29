CREATE PROCEDURE [dbo].[createEvent] (
	@actionName VARCHAR(20),
	@eventParameters VARCHAR(250) = NULL,
	@eventStartDate DATETIME = NULL
)

AS

DECLARE @errmsg NVARCHAR(128)

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

ELSE

BEGIN
	DECLARE @actionID INT = (SELECT actionID FROM dbo.Actions WHERE actionName = @actionName)
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
		SET @errmsg = 'actioName parameter not a key or action name!'
	END
END

IF @errmsg IS NOT NULL
BEGIN
	RAISERROR(@errmsg, 16, 1)
END
