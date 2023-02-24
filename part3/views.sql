-- 1

CREATE VIEW BasicInformation AS (SELECT idnr, St.name, login, St.program, Br.branch AS branch FROM
    Students AS St LEFT OUTER JOIN StudentBranches AS Br ON St.idnr = Br.student);


-- 2

CREATE VIEW FinishedCourses AS (SELECT student, course, grade, credits FROM Taken AS T JOIN Courses AS C ON T.course = C.code);



-- 3 

CREATE VIEW PassedCourses AS (SELECT student, course, credits FROM FinishedCourses 
    WHERE grade != 'U');


-- 4

CREATE VIEW Registrations AS (SELECT student, course, 'waiting' AS status FROM WaitingList
    UNION ALL
    SELECT student, course, 'registered' AS status FROM Registered);



------------------------------------------------ FUNCTIONS ------------------------------------------------

CREATE FUNCTION register_student( student TEXT, course TEXT ) RETURNS VOID AS $$ 
    BEGIN
        INSERT INTO Registered VALUES (student, course);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_student_to_waitinglist( student TEXT, course TEXT ) RETURNS VOID AS $$ 
    BEGIN
        INSERT INTO WaitingList VALUES (student, course, CURRENT_TIMESTAMP);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION remove_student_from_waitinglist( s TEXT, c TEXT ) RETURNS VOID AS $$
    BEGIN
        DELETE FROM WaitingList WHERE (student, course) = (s, c);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION unregister_student( s TEXT, c TEXT ) RETURNS VOID AS $$
    BEGIN 
        DELETE FROM Registered AS R WHERE (R.student, R.course) = (s, c);
        DELETE FROM WaitingList AS W WHERE (w.student, W.course) = (s, c);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION check_if_student_has_passed_course( s TEXT, c TEXT ) RETURNS BOOLEAN AS $$ 
    DECLARE 
        result BOOLEAN DEFAULT FALSE;
        grade CHAR(1);
    BEGIN
        grade := (SELECT Taken.grade FROM Taken WHERE (Taken.student, Taken.course) = (s, c));
        IF grade IN ('3', '4', '5') THEN
            result := TRUE;
        ELSE
            result := FALSE;
        END IF;
        RAISE NOTICE 'RESULT IS : %', result;
        RETURN result;
    END;    
$$ LANGUAGE plpgsql;

CREATE FUNCTION available_spot( c TEXT ) RETURNS BOOLEAN AS $$
    DECLARE
        cap INT;
        registred_students INT;
    BEGIN
        cap := (SELECT capacity FROM LimitedCourses WHERE code = c);
        registred_students := (SELECT COUNT(student) FROM Registered WHERE course = c);
        IF cap IS NULL THEN
            RETURN TRUE;
        ELSIF cap > registred_students THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION is_registred( s TEXT, c TEXT ) RETURNS BOOLEAN AS $$
    BEGIN
        IF (SELECT student FROM Registered WHERE (student, course) = (s, c)) IS NOT NULL THEN
            RETURN TRUE;
        ELSIF (SELECT student FROM WaitingList WHERE (student, course) = (s, c)) IS NOT NULL THEN
            RETURN TRUE;
        ELSE 
            RETURN FALSE;
        END IF;
    END;
$$ LANGUAGE plpgsql;
------------------------------------------------ TRIGGERS ------------------------------------------------
CREATE FUNCTION register() RETURNS TRIGGER AS $register$
    DECLARE
        prereq CURSOR(pre_course TEXT) FOR SELECT requirement FROM Prerequisites WHERE course = pre_course;
        req TEXT;
        grade CHAR(1);
    BEGIN         
        -- Checks if student is already registred or on waitinglist : 

        IF (SELECT * FROM is_registred( NEW.student, NEW.course )) THEN
            RAISE EXCEPTION 'STUDENT % IS ALREADY REGISTRED OR IN WAITINGLIST FOR COURSE %', NEW.student, NEW.course;
        END IF;

        -- Checks if prerequisites are met : COMPLETED

        OPEN prereq(NEW.course);
        LOOP    
            FETCH NEXT FROM prereq INTO req;
            EXIT WHEN NOT FOUND;
            grade := (SELECT Taken.grade FROM Taken WHERE (student, course) = (NEW.student, req));
            IF grade IS NULL THEN 
                RAISE EXCEPTION 'Student % does not fulfill the requirements set by Course % : NO RECORD', NEW.student, NEW.course;
            ELSIF grade = 'U' THEN
                RAISE NOTICE 'Student % does not fulfill the requirements set by Course % : ', NEW.student, NEW.course;
                RAISE EXCEPTION ' HAS NOT PASSED COURSE %', req;
            END IF;
        END LOOP;
        CLOSE prereq;
        -- DEALLOCATE prereq; ??????

        --  Checks if course capacity allows a registration : COMPLETED



        IF (SELECT * FROM available_spot(NEW.course)) THEN 
            PERFORM register_student(NEW.student, NEW.course);
        ELSE
            PERFORM add_student_to_waitinglist(NEW.student, NEW.course);
        END IF;

        RETURN NULL;
    END;
$register$ LANGUAGE plpgsql;

--     UNCOMMENT TO DEACTIVATE REGISTER FUNCTION 

CREATE TRIGGER register INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION register();


CREATE FUNCTION unregister() RETURNS TRIGGER AS $unregister$
    DECLARE
        waiting_students CURSOR(wait_course TEXT) FOR SELECT student FROM WaitingList WHERE course = wait_course;
        first_student TEXT;
    BEGIN
        PERFORM unregister_student( OLD.student, OLD.course );

        IF (SELECT * FROM available_spot( OLD.course )) THEN
            OPEN waiting_students( OLD.course );
            FETCH FROM waiting_students INTO first_student;
            CLOSE waiting_students;
            IF first_student IS NULL THEN 
                RETURN NULL;
            END IF;
            PERFORM register_student( first_student, OLD.course );
            PERFORM remove_student_from_waitinglist( first_student, OLD.course );
        END IF;

        RETURN NULL;
    END;
$unregister$ LANGUAGE plpgsql;

CREATE TRIGGER unregister INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();

------------------------------------------------ TEST ------------------------------------------------


CREATE FUNCTION test() RETURNS TRIGGER AS $test$
    DECLARE
        test1 BOOLEAN;
    BEGIN
        test1 := (SELECT * FROM check_if_student_has_passed_course('5555555555', 'CCC111'));
        IF test1 IS TRUE THEN
            RAISE NOTICE 'HURR DURR';
        END IF;
        RAISE NOTICE 'check is : %', test1;
        RETURN NULL;
    END;

$test$ LANGUAGE plpgsql;


--   UNCOMMENT TO DEACTIVATE TEST FUNCTION

--CREATE TRIGGER test INSTEAD OF INSERT ON Registrations
--    FOR EACH ROW EXECUTE FUNCTION test();

-- 5

CREATE VIEW UnreadMandatory AS (
    WITH 
        StudentMandatoryProgramCourses AS (
            SELECT idnr AS student, course FROM Students AS S JOIN 
            ProgramMandatoryCourses AS M ON S.program = M.program
        ), StudentMandatoryBranchCourses AS (
            SELECT student, course FROM StudentBranches AS SB JOIN
            BranchMandatoryCourses AS MB ON (SB.branch, SB.program) = (MB.branch, MB.program)
        ), StudentMandatoryCourses AS (
            SELECT student, course FROM StudentMandatoryBranchCourses 
            UNION SELECT student, course FROM StudentMandatoryProgramCourses
        )
    SELECT student, course FROM StudentMandatoryCourses 
    WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses)
);

--CREATE VIEW UnreadMandatory AS

-- 6

CREATE VIEW PathToGraduation AS (
    WITH
        TotalCredits AS (
            SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student
        ), MandatoryLeft AS (
            SELECT BI.idnr AS student, COALESCE(COUNT(course), 0) AS mandatoryLeft FROM BasicInformation AS BI 
            LEFT OUTER JOIN UnreadMandatory AS UM ON BI.idnr = UM.student GROUP BY BI.idnr
        ), MathCredits AS (
            SELECT student, SUM(credits) AS mathCredits FROM PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
            WHERE classification = 'math' GROUP BY student
        ), ResearchCredits AS (
            SELECT student, SUM(credits) AS researchCredits FROM PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
            WHERE classification = 'research' GROUP BY student
        ), SeminarCourses AS (
            SELECT student, COUNT(C.course) AS seminarCourses FROM PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
            WHERE classification = 'seminar' GROUP BY student
        ), RecommendedCourses AS (
            SELECT student, course, credits AS recommendedCredits FROM StudentBranches AS SB JOIN BranchRecommendedCourses AS RB
            ON (SB.branch, SB.program) = (RB.branch, RB.program) JOIN Courses AS C ON course = code
        ), RecommendedCredits AS (
            SELECT BI.idnr AS student, COALESCE(SUM(RC.recommendedCredits), 0)AS RecommendedCredits FROM
            BasicInformation AS BI LEFT OUTER JOIN RecommendedCourses AS RC ON BI.idnr = RC.student
            LEFT OUTER JOIN Taken AS T ON (RC.student, RC.course) = (T.student, T.course) WHERE grade != 'U' GROUP BY BI.idnr
        )
    
    SELECT ST.student, COALESCE(totalCredits, 0) AS totalCredits, mandatoryLeft, 
    COALESCE(mathCredits, 0) AS mathCredits, COALESCE(researchCredits, 0) AS researchCredits,
    COALESCE(seminarCourses, 0) AS seminarCourses, CASE WHEN (
        mandatoryLeft = 0 AND recommendedCredits >= 10 AND mathCredits >= 20 AND 
        researchCredits >= 10 AND SeminarCourses >= 1) THEN TRUE ELSE FALSE END
    AS qualified FROM
    (SELECT idnr AS student FROM BasicInformation) AS ST FULL OUTER JOIN TotalCredits ON ST.student = TotalCredits.student
    FULL OUTER JOIN MandatoryLeft ON ST.student = MandatoryLeft.student
    FULL OUTER JOIN RecommendedCredits ON ST.student = RecommendedCredits.student
    FULL OUTER JOIN MathCredits ON ST.student = MathCredits.student
    FULL OUTER JOIN ResearchCredits ON ST.student = ResearchCredits.student
    FULL OUTER JOIN SeminarCourses ON ST.student = SeminarCourses.student
);


-- 7

CREATE VIEW CourseQueuePositions AS (
    SELECT student, course, ROW_NUMBER() OVER (PARTITION BY course ORDER BY position) as position FROM WaitingList
);