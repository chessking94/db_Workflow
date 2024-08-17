CREATE TABLE [dbo].[stage_WorkflowActions]
(
	[stagingKey] INT IDENTITY(1,1) NOT NULL,
	[workflowID] SMALLINT NOT NULL,
	[stepNumber] TINYINT NOT NULL,
	[actionID] INT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[continueAfterError] BIT NULL,
	--TODO: [runConcurrent] BIT NULL,
	CONSTRAINT [PK_sWorkflowActions] PRIMARY KEY ([stagingKey]),
	CONSTRAINT [FK_sWorkflowActions_Workflows] FOREIGN KEY ([workflowID]) REFERENCES dbo.Workflows([workflowID]),
	CONSTRAINT [FK_sWorkflowActions_Actions] FOREIGN KEY ([actionID]) REFERENCES dbo.Actions([actionID])
)
