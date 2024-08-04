CREATE TABLE [dbo].[stage_WorkflowActions]
(
	[workflowID] SMALLINT NOT NULL,
	[stepNumber] TINYINT NOT NULL,
	[actionID] INT NOT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[continueAfterError] BIT NOT NULL,
	--TODO: [runConcurrent] BIT NOT NULL,
	CONSTRAINT [FK_sWorkflowActions_Workflows] FOREIGN KEY ([workflowID]) REFERENCES dbo.Workflows([workflowID]),
	CONSTRAINT [FK_sWorkflowActions_Actions] FOREIGN KEY ([actionID]) REFERENCES dbo.Actions([actionID])
)
