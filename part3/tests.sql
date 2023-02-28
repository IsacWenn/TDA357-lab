--------------------------------------------------------------------------------------------------------------------------
-- TEST #1: REGISTER STUDENT TO AN UNLIMITED COURSE
-- EXPECTED OUTCOME : PASS
INSERT INTO Registrations VALUES ('4444444444', 'TTT111');

-- TEST #2: REGISTER STUDENT TO A LIMITED COURSE
-- EXPECTED OUTCOME : PASS
INSERT INTO Registrations VALUES ('3333333333', 'TTT222');

-- TEST #3: REGISTER STUDENT TO A FULL LIMITED COURSE SHOULD ADD THEM TO WAITINGLIST
-- EXPECTED OUTCOME : PASS
INSERT INTO Registrations VALUES ('5555555555', 'TTT222');

-- TEST #4: REMOVE STUDENT FROM A LIMITED COURSE WHILE ON THE WAITINGLIST
-- EXPECTED OUTCOME : PASS
DELETE FROM Registrations WHERE (student, course) = ('2222222222', 'TTT222');

-- TEST #5: REMOVE STUDENT FROM UNLIMITED COURSE
-- EXPECTED OUTCOME : PASS
DELETE FROM Registrations WHERE (student, course) = ('1111111111', 'CCC111'); 

-- TEST #6: REGISTER STUDENT TO A LIMITED COURSE
-- EXPECTED OUTCOME : PASS
INSERT INTO Registrations VALUES ('1111111111', 'TTT333');

-- TEST #7: REMOVE STUDENT FROM LIMITED COURSE WITHOUT WAITINGLIST
-- EXPECTED OUTCOME : PASS
DELETE FROM Registrations WHERE (student, course) = ('1111111111', 'TTT333');

-- TEST #8: REMOVE STUDENT FROM LIMITED COURSE WITH WAITINGLIST WHILE REGISTRED
-- EXPECTED OUTCOME : PASS
DELETE FROM Registrations WHERE (student, course) = ('3333333333', 'TTT222');

-- TEST #9: UNREGISTER STUDENT FROM OVERFULL LIMITED COURSE WHILE WITH A WAITINGLIST
-- EXPECTED OUTCOME : PASS
DELETE FROM Registrations WHERE (student, course) = ('2222222222', 'TTT444');

-- TEST #10: REGISTERING STUDENT FOR AN UNLIMITED COURSE THEY ARE ALREADY REGISTRED TO SHOULD FAIL
-- EXPECTED OUTCOME : FAIL
INSERT INTO Registrations VALUES ('4444444444', 'TTT111');

--------------------------------------------------------------------------------------------------------------------------