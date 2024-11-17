CREATE TABLE [temp].[ErrorReviewCompleted]
(
	[eventID] INT NOT NULL,
	CONSTRAINT [PK_ErrorReviewCompleted] PRIMARY KEY CLUSTERED ([eventID] ASC),
	CONSTRAINT [FK_ErrorReviewCompleted_Events] FOREIGN KEY ([eventID]) REFERENCES [dbo].[Events] ([eventID])
)
