CREATE PROCEDURE [dbo].[updateEventStatus] (@eventID AS INT, @eventStatus AS VARCHAR(10))

AS

DECLARE @errmsg NVARCHAR(128)
IF NOT EXISTS (SELECT eventID FROM dbo.Events WHERE eventID = @eventID)
BEGIN
	SET @errmsg = 'eventID passed not found!'
END

IF @errmsg IS NULL
	BEGIN
	--if @eventStatus is a key value from dbo.EventStatuses, use that
	IF EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = @eventStatus)
	BEGIN
		UPDATE dbo.Events
		SET eventStatusID = @eventStatus
		WHERE eventID = @eventID
	END

	ELSE

	BEGIN
		DECLARE @eventStatusID SMALLINT = (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatus = @eventStatus)
		IF @eventStatusID IS NOT NULL
		BEGIN
			UPDATE dbo.Events
			SET eventStatusID = @eventStatusID
			WHERE eventID = @eventID
		END

		ELSE

		BEGIN
			SET @errmsg = 'eventStatus parameter not a key or status name!'
		END
	END
END

IF @errmsg IS NOT NULL
BEGIN
	RAISERROR(@errmsg, 16, 1)
END
