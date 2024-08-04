CREATE TABLE [dbo].[WorkflowActions]
(
	[workflowID] SMALLINT NOT NULL,
	[stepNumber] TINYINT NOT NULL,
	[actionID] INT NOT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[continueAfterError] BIT NOT NULL,
	--TODO: [runConcurrent] BIT NOT NULL,
	CONSTRAINT [PK_WorkflowActions] PRIMARY KEY ([workflowID] ASC, [stepNumber] ASC),
	CONSTRAINT [FK_WorkflowActions_Workflows] FOREIGN KEY ([workflowID]) REFERENCES dbo.Workflows([workflowID]),
	CONSTRAINT [FK_WorkflowActions_Actions] FOREIGN KEY ([actionID]) REFERENCES dbo.Actions([actionID])
)
