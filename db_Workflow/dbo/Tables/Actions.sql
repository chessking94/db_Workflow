CREATE TABLE [dbo].[Actions]
(
	[actionID] INT IDENTITY(1,1) NOT NULL,
	[actionName] VARCHAR(20) NOT NULL,
	[actionDescription] VARCHAR(100) NOT NULL,
	[actionActive] BIT CONSTRAINT [DF_Actions_Active] DEFAULT ((0)) NOT NULL,
	[actionRequireParameters] BIT CONSTRAINT [DF_Actions_Parameters] DEFAULT ((0)) NOT NULL,
	[actionConcurrency] TINYINT CONSTRAINT [DF_Actions_Concurrency] DEFAULT ((1)) NOT NULL,
	[applicationID] INT NULL,
    CONSTRAINT [PK_Actions] PRIMARY KEY CLUSTERED ([actionID] ASC),
	CONSTRAINT [UC_Actions_Name] UNIQUE NONCLUSTERED ([actionName] ASC),
	CONSTRAINT [FK_Actions_Applications] FOREIGN KEY ([applicationID]) REFERENCES [dbo].[Applications] ([applicationID])
)
