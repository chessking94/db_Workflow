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

/* Perform the necessary user/role checks for the environment login */
DECLARE @server varchar(15) = @@SERVERNAME
DECLARE @login_name varchar(25)
DECLARE @xsql nvarchar(500)
DECLARE @login_ct tinyint
DECLARE @user_ct tinyint
DECLARE @role_ct tinyint
DECLARE @exec_perm tinyint

--get username for environment and verify it exists on the server
IF @server LIKE '%dev%'
BEGIN
	SET @login_name = 'automation_user'
END
ELSE
BEGIN
	SET @login_name = 'automation_user'
END

SET @xsql = 'SELECT @loginctOUT = COUNT(name) FROM sys.server_principals WHERE name = ''' + @login_name + ''' AND type_desc = ''SQL_LOGIN'''
EXEC sp_executesql @xsql, N'@loginctOUT tinyint OUTPUT', @loginctOUT=@login_ct OUTPUT
IF @login_ct = 0
BEGIN
	RAISERROR('The user does not exist', 16, 1)
	RETURN
END

--create user on database if it does not already exist
SET @xsql = 'SELECT @userctOUT = COUNT(name) FROM sys.database_principals WHERE name = ''' + @login_name + ''''
EXEC sp_executesql @xsql, N'@userctOUT tinyint OUTPUT', @userctOUT=@user_ct OUTPUT
IF @user_ct = 0
BEGIN
	SET @xsql = 'CREATE USER [' + @login_name + '] FOR LOGIN [' + @login_name + '] WITH DEFAULT_SCHEMA=[dbo]'
	EXEC sp_executesql @xsql
	PRINT 'User created on database'
END

--the environment login should have db_datareader and db_datawriter roles on the database, check if assigned and assign if not
SET @xsql = '
SELECT
@rolectOUT = COUNT(dp2.name)

FROM sys.database_principals AS dp
JOIN sys.database_role_members AS drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals AS dp2 ON drm.role_principal_id = dp2.principal_id

WHERE dp2.name = ''db_datawriter''
AND dp.name = ''' + @login_name + ''''

EXEC sp_executesql @xsql, N'@rolectOUT tinyint OUTPUT', @rolectOUT=@role_ct OUTPUT
IF @role_ct = 0
BEGIN
	--db_datawriter does not exist, add it
	SET @xsql = 'ALTER ROLE [db_datawriter] ADD MEMBER [' + @login_name + ']'
	EXEC sp_executesql @xsql
	PRINT 'Added db_datawriter role to user'
END

SET @xsql = '
SELECT
@rolectOUT = COUNT(dp2.name)

FROM sys.database_principals AS dp
JOIN sys.database_role_members AS drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals AS dp2 ON drm.role_principal_id = dp2.principal_id

WHERE dp2.name = ''db_datareader''
AND dp.name = ''' + @login_name + ''''

EXEC sp_executesql @xsql, N'@rolectOUT tinyint OUTPUT', @rolectOUT=@role_ct OUTPUT
IF @role_ct = 0
BEGIN
	--db_datareader does not exist, add it
	SET @xsql = 'ALTER ROLE [db_datareader] ADD MEMBER [' + @login_name + ']'
	EXEC sp_executesql @xsql
	PRINT 'Added db_datareader role to user'
END

--the environment login should also have execute permissions on ChessWarehouse
SET @xsql = '
SELECT
@execpermOUT = COUNT(dp.name)

FROM sys.database_principals dp
JOIN sys.database_permissions perm ON dp.principal_id = perm.grantee_principal_id

WHERE perm.permission_name = ''EXECUTE''
AND dp.name = ''' + @login_name + ''''

EXEC sp_executesql @xsql, N'@execpermOUT tinyint OUTPUT', @execpermOUT=@exec_perm OUTPUT
IF @exec_perm = 0
BEGIN
	--permission does not exist, add it
	SET @xsql = 'GRANT EXECUTE TO [' + @login_name + ']'
	EXEC sp_executesql @xsql
	PRINT 'Added EXECUTE permission on database to user'
END

/* Insert seed data */
--Schema: dbo
----Table: EventStatuses
SET IDENTITY_INSERT dbo.EventStatuses ON

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '0', 'Pending', '0'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '0')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '1', 'Queued', '0'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '1')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '2', 'Processing','0'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '2')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '3', 'Complete', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '3')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '4', 'Cancelled', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '4')

INSERT INTO dbo.EventStatuses (eventStatusID, eventStatus, isTerminal)
SELECT '5', 'Error', '1'
WHERE NOT EXISTS (SELECT eventStatusID FROM dbo.EventStatuses WHERE eventStatusID = '5')

SET IDENTITY_INSERT dbo.EventStatuses OFF
