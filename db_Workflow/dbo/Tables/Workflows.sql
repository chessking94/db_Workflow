CREATE TABLE [dbo].[Workflows]
(
	[workflowID] SMALLINT IDENTITY(1,1) NOT NULL,
	[workflowName] VARCHAR(50) NOT NULL,
	[workflowDescription] VARCHAR(100) NOT NULL,
	[workflowActive] BIT CONSTRAINT [DF_Workflows_Active] DEFAULT ((0)) NOT NULL,
	[workflowCreateDate] DATETIME CONSTRAINT [DF_Workflows_CreateDate] DEFAULT (GETDATE()) NOT NULL,
	CONSTRAINT PK_Workflows PRIMARY KEY CLUSTERED ([workflowID] ASC),
	CONSTRAINT [UC_Workflows_Name] UNIQUE NONCLUSTERED ([workflowName] ASC)
)
