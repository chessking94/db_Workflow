CREATE TABLE [temp].[ErrorReviewPending]
(
	[eventID] INT NOT NULL,
	CONSTRAINT [PK_ErrorReviewPending] PRIMARY KEY CLUSTERED ([eventID] ASC),
	CONSTRAINT [FK_ErrorReviewPending_Events] FOREIGN KEY ([eventID]) REFERENCES [dbo].[Events] ([eventID])
)
