CREATE TABLE [dbo].[ApplicationTypes]
(
	[applicationTypeID] TINYINT IDENTITY(1,1) NOT NULL,
	[applicationType] VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_ApplicationTypes] PRIMARY KEY CLUSTERED ([applicationTypeID] ASC),
	CONSTRAINT [UC_ApplicationTypes_Type] UNIQUE NONCLUSTERED ([applicationType] ASC)
)
