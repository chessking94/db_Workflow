CREATE TABLE [dbo].[Workflows]
(
	[workflowID] SMALLINT IDENTITY(1,1) NOT NULL,
	[workflowName] VARCHAR(20) NOT NULL,
	[workflowDescription] VARCHAR(100) NOT NULL,
	[workflowActive] BIT CONSTRAINT [DF_Workflow_Active] DEFAULT ((0)) NOT NULL,
	CONSTRAINT PK_Workflows PRIMARY KEY CLUSTERED ([workflowID] ASC),
	CONSTRAINT [UC_Workflows_Name] UNIQUE NONCLUSTERED ([workflowName] ASC)
)
