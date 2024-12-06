/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

USE Workflow
GO

--set the owner
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'database_owner' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "database_owner" does not exist', 16, 1)
	RETURN
END

EXEC sp_changedbowner 'database_owner'

--set permissions for other logins
----automation_user
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'automation_user' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "automation_user" does not exist', 16, 1)
	RETURN
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'automation_user')
BEGIN
	CREATE USER [automation_user] FOR LOGIN [automation_user] WITH DEFAULT_SCHEMA = [dbo]
END

ALTER ROLE [db_datareader] ADD MEMBER [automation_user]
ALTER ROLE [db_datawriter] ADD MEMBER [automation_user]
ALTER ROLE [db_executor] ADD MEMBER [automation_user]

----job_owner
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'job_owner' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "job_owner" does not exist', 16, 1)
	RETURN
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'job_owner')
BEGIN
	CREATE USER [job_owner] FOR LOGIN [job_owner] WITH DEFAULT_SCHEMA = [dbo]
END

ALTER ROLE [db_datareader] ADD MEMBER [job_owner]
ALTER ROLE [db_datawriter] ADD MEMBER [job_owner]
ALTER ROLE [db_executor] ADD MEMBER [job_owner]
ALTER ROLE [db_ddladmin] ADD MEMBER [job_owner]
ALTER ROLE [db_backupoperator] ADD MEMBER [job_owner]

/* Insert seed data */
--Schema: dbo
----Table: EventStatuses
INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, inProgress, isTerminal)
SELECT '-1', 'Error', '0', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '-1')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, inProgress, isTerminal)
SELECT '0', 'Cancelled', '0', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '0')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, inProgress, isTerminal)
SELECT '1', 'Complete', '0', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '1')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, inProgress, isTerminal)
SELECT '2', 'Pending', '0', '0'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '2')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, inProgress, isTerminal)
SELECT '3', 'Processing', '1', '0'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '3')

----Table: Recurrences
SET IDENTITY_INSERT dbo.Recurrences ON

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '0', 'One-Time'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '0')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '1', 'Minutely'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '1')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '2', 'Hourly'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '2')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '3', 'Daily'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '3')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '4', 'Weekly'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '4')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '5', 'Monthly'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '5')

INSERT INTO dbo.Recurrences (recurrenceID, recurrenceName)
SELECT '6', 'Yearly'
WHERE NOT EXISTS (SELECT recurrenceID FROM dbo.Recurrences WHERE recurrenceID = '6')

SET IDENTITY_INSERT dbo.Recurrences OFF

----Table: ApplicationTypes
SET IDENTITY_INSERT dbo.ApplicationTypes ON

INSERT INTO dbo.ApplicationTypes (applicationTypeID, applicationType)
SELECT '1', 'Python Script'
WHERE NOT EXISTS (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationTypeID = '1')

INSERT INTO dbo.ApplicationTypes (applicationTypeID, applicationType)
SELECT '2', 'Batch Script'
WHERE NOT EXISTS (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationTypeID = '2')

INSERT INTO dbo.ApplicationTypes (applicationTypeID, applicationType)
SELECT '3', 'Executable'
WHERE NOT EXISTS (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationTypeID = '3')

INSERT INTO dbo.ApplicationTypes (applicationTypeID, applicationType)
SELECT '4', 'Stored Procedure'
WHERE NOT EXISTS (SELECT applicationTypeID FROM dbo.ApplicationTypes WHERE applicationTypeID = '4')

SET IDENTITY_INSERT dbo.ApplicationTypes OFF
