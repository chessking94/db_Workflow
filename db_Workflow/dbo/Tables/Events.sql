CREATE TABLE [dbo].[Events]
(
	[eventID] INT IDENTITY(1,1) NOT NULL,
	[actionID] INT NOT NULL,
	[eventParameters] VARCHAR(250) NULL,
	[eventStatusID] SMALLINT CONSTRAINT [DF_Events_Status] DEFAULT ((0)) NOT NULL,
	[eventCreateDate] DATETIME CONSTRAINT [DF_Events_CreateDate] DEFAULT (getdate()) NOT NULL,
	[eventStatusDate] DATETIME CONSTRAINT [DF_Events_StatusDate] DEFAULT (getdate()) NOT NULL,
	[eventEndDate] DATETIME NULL,
    CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED ([eventID] ASC),
	CONSTRAINT [FK_Events_actionID] FOREIGN KEY ([actionID]) REFERENCES [dbo].[Actions] ([actionID]),
	CONSTRAINT [FK_Events_eventStatusID] FOREIGN KEY ([eventStatusID]) REFERENCES [dbo].[EventStatuses] ([eventStatusID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_Events_actionID]
    ON [dbo].[Events]([actionID] ASC);