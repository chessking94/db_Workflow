CREATE PROCEDURE [temp].[insertErrorReview]

AS

BEGIN
	TRUNCATE TABLE temp.ErrorReviewPending
	
	INSERT INTO temp.ErrorReviewPending (
		eventID
	)

	SELECT
	e.eventID

	FROM dbo.Events e
	JOIN dbo.EventStatuses es ON
		e.eventStatusID = es.eventStatusID
	LEFT JOIN temp.ErrorReviewCompleted rvw ON
		e.eventID = rvw.eventID

	WHERE es.isTerminal = 1
	AND e.eventEndDate >= CAST(GETDATE() AS DATE)
	AND rvw.eventID IS NULL
END
