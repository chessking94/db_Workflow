CREATE TABLE [dbo].[EventStatuses]
(
	[eventStatusID] SMALLINT NOT NULL,
	[eventStatus] VARCHAR(10) NOT NULL,
	[inProgress] BIT CONSTRAINT [DF_EventStatuses_Progress] DEFAULT ((1)) NOT NULL,
	[isTerminal] BIT CONSTRAINT [DF_EventStatuses_Terminal] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_EventStatuses] PRIMARY KEY CLUSTERED ([eventStatusID] ASC),
	CONSTRAINT [UC_EventStatuses_Status] UNIQUE NONCLUSTERED ([eventStatus] ASC)
)
