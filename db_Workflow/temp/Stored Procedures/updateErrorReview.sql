CREATE PROCEDURE [temp].[updateErrorReview]

AS

BEGIN
	INSERT INTO temp.ErrorReviewCompleted (
		eventID
	)

	SELECT
	p.eventID

	FROM temp.ErrorReviewPending p
	LEFT JOIN temp.ErrorReviewCompleted c ON
		p.eventID = c.eventID

	WHERE c.eventID IS NULL
END
