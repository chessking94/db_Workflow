CREATE TABLE [dbo].[Applications]
(
	[applicationID] INT IDENTITY(1,1) NOT NULL,
	[applicationName] VARCHAR(50) NOT NULL,
	[applicationDescription] VARCHAR(100) NOT NULL,
	[applicationFilename] VARCHAR(250) NOT NULL,
	[applicationActive] BIT CONSTRAINT [DF_Applications_Active] DEFAULT ((0)) NOT NULL,
	[applicationCreateDate] DATETIME CONSTRAINT [DF_Applications_CreateDate] DEFAULT (GETDATE()) NOT NULL,
	[applicationDefaultParameter] VARCHAR(250) NULL,
	[applicationTypeID] TINYINT NOT NULL,
	CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED ([applicationID] ASC),
	CONSTRAINT [UC_Applications_Name] UNIQUE NONCLUSTERED ([applicationName] ASC),
	CONSTRAINT [FK_Applications_ApplicationTypes] FOREIGN KEY ([applicationTypeID]) REFERENCES [dbo].[ApplicationTypes] ([applicationTypeID])
)
