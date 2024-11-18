CREATE PROCEDURE [temp].[ClearTempTables]

AS

/*
	The intent of this procedure is to be executed *once per day* as part of a clean-up night job.
	Due to that, it is written in such a way to not impact any record associated with today's date.
*/

BEGIN
	--temp.ErrorReviewCompleted
	DELETE t
	FROM temp.ErrorReviewCompleted t
	JOIN dbo.Events e ON
		t.eventID = e.eventID
	WHERE e.eventEndDate < CAST(GETDATE() AS DATE)
END
