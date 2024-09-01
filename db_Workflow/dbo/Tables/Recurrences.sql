CREATE TABLE [dbo].[Recurrences]
(
	[recurrenceID] TINYINT IDENTITY(1,1) NOT NULL,
	[recurrenceName] VARCHAR(8) NOT NULL,
	CONSTRAINT [PK_Recurrences] PRIMARY KEY CLUSTERED ([recurrenceID] ASC),
	CONSTRAINT [UC_Recurrences_Name] UNIQUE NONCLUSTERED ([recurrenceName] ASC)
)
