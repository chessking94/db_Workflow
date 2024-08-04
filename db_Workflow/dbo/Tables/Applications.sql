CREATE TABLE [dbo].[Applications]
(
	[applicationID] INT IDENTITY(1,1) NOT NULL,
	[applicationName] VARCHAR(20) NOT NULL,
	[applicationDescription] VARCHAR(100) NOT NULL,
	[applicationFilename] VARCHAR(250) NOT NULL,
	[applicationActive] BIT CONSTRAINT [DF_Applications_Active] DEFAULT ((0)) NOT NULL,
	[applicationDefaultParameter] VARCHAR(250) NULL,
	CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED ([applicationID] ASC),
	CONSTRAINT [UC_Applications_Name] UNIQUE NONCLUSTERED ([applicationName] ASC)
)
