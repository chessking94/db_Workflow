/*
	A sequence of inserts to generate testable data for the database "Workflow"
*/

--dbo.Applications
SET IDENTITY_INSERT dbo.Applications ON

INSERT INTO dbo.Applications (applicationID, applicationName, applicationDescription, applicationFilename, applicationActive)
VALUES (1, 'MyTestApp1', 'Testing Application 1', 'C:\Users\User\app1.exe', 1)

INSERT INTO dbo.Applications (applicationID, applicationName, applicationDescription, applicationFilename, applicationActive)
VALUES (2, 'MyTestApp2', 'Testing Application 2', 'C:\Users\User\app2.exe', 0)

SET IDENTITY_INSERT dbo.Applications OFF

--dbo.Actions
SET IDENTITY_INSERT dbo.Actions ON

INSERT INTO dbo.Actions (actionID, actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, applicationID)
VALUES (1, 'MyTestAction1', 'Testing Action 1', 1, 0, 1, 1)

INSERT INTO dbo.Actions (actionID, actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, applicationID)
VALUES (2, 'MyTestAction2', 'Testing Action 2', 1, 1, 1, NULL)

INSERT INTO dbo.Actions (actionID, actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, applicationID)
VALUES (3, 'MyTestAction3', 'Testing Action 3', 0, 0, 1, NULL)

INSERT INTO dbo.Actions (actionID, actionName, actionDescription, actionActive, actionRequireParameters, actionConcurrency, applicationID)
VALUES (4, 'MyTestAction4', 'Testing Action 4', 1, 0, 1, 2)

SET IDENTITY_INSERT dbo.Actions OFF

--dbo.Workflows
SET IDENTITY_INSERT dbo.Workflows ON

INSERT INTO dbo.Workflows (workflowID, workflowName, workflowDescription, workflowActive)
VALUES (1, 'MyTestWorkflow1', 'Testing Workflow 1', 1)

INSERT INTO dbo.Workflows (workflowID, workflowName, workflowDescription, workflowActive)
VALUES (2, 'MyTestWorkflow2', 'Testing Workflow 2', 0)

INSERT INTO dbo.Workflows (workflowID, workflowName, workflowDescription, workflowActive)
VALUES (3, 'MyTestWorkflow3', 'Testing Workflow 3', 1)

SET IDENTITY_INSERT dbo.Workflows OFF

--dbo.stage_WorkflowActions
----testing workflow 1
INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (1, 1, 1, NULL, 1)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (1, 2, 2, 'parameter placeholder', 0)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (1, 3, 3, NULL, 1)

EXEC createWorkflowActions @workflowID = 1

----testing workflow 2
INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (2, 1, 1, NULL, 1)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (2, 2, 2, 'parameter placeholder', 0)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (2, 3, 3, NULL, 1)

EXEC createWorkflowActions @workflowID = 2

----testing workflow 3
INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (3, 1, 1, NULL, 0)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (3, 2, 2, 'parameter placeholder', 0)

INSERT INTO dbo.stage_WorkflowActions (workflowID, stepNumber, actionID, eventParameters, continueAfterError)
VALUES (3, 3, 3, NULL, 0)

EXEC createWorkflowActions @workflowID = 3


--Need to test these scenarios one at a time

--dbo.Events
SET IDENTITY_INSERT dbo.Events ON
----scenario 1: action 1, not connected to a workflow
----expected results: 
/*
	dbo.canStartEvent @eventID = 1 returns a recordset of 1
	dbo.updateEventStatus @eventID = 0, @eventStatus = 3 raises an error saying "eventID not found!"
	dbo.updateEventStatus @eventID = 1, @eventStatus = 3 is successful
*/
INSERT INTO dbo.Events (eventID, actionID, eventParameters, eventStartDate)
VALUES (1, 1, NULL, GETDATE())

----scenario 2: action 2, not connected to a workflow
----expected results:
/*
	dbo.canStartEvent @eventID = 2 returns a recordset of 0, errors event and updates eventError to "Action missing parameters"
*/
INSERT INTO dbo.Events (eventID, actionID, eventParameters, eventStartDate)
VALUES (2, 2, NULL, GETDATE())

----scenario 3: action 3, not connected to a workflow
----expected results:
/*
	dbo.canStartEvent @eventID = 3 returns a recordset of 0, cancels event and updates eventError to "Action inactive"
*/
INSERT INTO dbo.Events (eventID, actionID, eventParameters, eventStartDate)
VALUES (3, 3, NULL, GETDATE())

----scenario 4: action 4, not connected to a workflow
----expected results:
/*
	dbo.canStartEvent @eventID = 4 returns a recordset of 0, cancels event and updates eventError to "Application inactive"
*/
INSERT INTO dbo.Events (eventID, actionID, eventParameters, eventStartDate)
VALUES (4, 4, NULL, GETDATE())

----scenario 5: workflow 1 steps
----expected results:
/*
	dbo.canStartEvent @eventID = 5 does nothing (eventID = 1 is currently processing)
	dbo.updateEventStatus @eventID = 1, @eventStatus = 1 is successful
	dbo.canStartEvent @eventID = 5 returns a recordset of 1
	dbo.updateEventStatus @eventID = 5, @eventStatus = 3 is successful
	dbo.canStartEvent @eventID = 6 does nothing (eventID = 5 is currently processing)
	dbo.updateEventStatus @eventID = 5, @eventStatus = 1 is successful
	dbo.canStartEvent @eventID = 6 returns a recordset of 1
	dbo.updateEventStatus @eventID = 6, @eventStatus = 3 is successful
	dbo.updateEventStatus @eventID = 6, @eventStatus = 1 is successful
	dbo.canStartEvent @eventID = 7 returns a recordset of 0, cancels event and updates eventError to "Action inactive"
*/
INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (5, 1, 1, 1, NULL, GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (6, 1, 2, 2, 'test parameters', GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (7, 1, 3, 3, NULL, GETDATE())

----scenario 6: workflow 2 steps
----expected results:
/*
	dbo.canStartEvent @eventID = 8 returns a recordset of 0, cancels event and updates eventError to "Workflow inactive"
	dbo.canStartEvent @eventID = 9 returns a recordset of 0, cancels event and updates eventError to "Workflow inactive"
	dbo.canStartEvent @eventID = 10 returns a recordset of 0, cancels event and updates eventError to "Workflow inactive"
*/
INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (8, 2, 1, 1, NULL, GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (9, 2, 2, 2, NULL, GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (10, 2, 3, 3, NULL, GETDATE())

----scenario 7: workflow 3 steps
----expected results:
/*
	dbo.canStartEvent @eventID = 11 returns a recordset of 1
	dbo.updateEventStatus @eventID = 11, @eventStatus = -1, @eventError = 'test error' is successful
	eventID's 12 and 13 should auto-cancel after updating eventID 11 to an error
*/

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (11, 3, 1, 1, NULL, GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (12, 3, 2, 2, 'test parameters', GETDATE())

INSERT INTO dbo.Events (eventID, workflowID, stepNumber, actionID, eventParameters, eventStartDate)
VALUES (13, 3, 3, 3, NULL, GETDATE())

SET IDENTITY_INSERT dbo.Events OFF
