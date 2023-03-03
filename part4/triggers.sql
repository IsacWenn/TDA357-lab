------------------------------------------------ VIEW ------------------------------------------------

CREATE VIEW CourseQueuePositions AS (
    SELECT student, course, ROW_NUMBER() OVER (PARTITION BY course ORDER BY position) as place FROM WaitingList
);

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
        grade CHAR(1);

        prereq_alt1 TEXT[];
    BEGIN         
        -- Checks if student is already registred or on waitinglist : COMPLETED

        IF (SELECT * FROM is_registred( NEW.student, NEW.course )) THEN
            RAISE EXCEPTION 'STUDENT % IS ALREADY REGISTRED OR IN WAITINGLIST FOR COURSE %', NEW.student, NEW.course;
        END IF;

        -- Checks if prerequisites are met : COMPLETED

        IF (SELECT COUNT(c) FROM (SELECT requirement AS c FROM Prerequisites AS PR WHERE PR.course = NEW.course 
                                 EXCEPT
                                 SELECT course FROM PassedCourses AS PC WHERE PC.student = NEW.student) AS foo) != 0 THEN
            RAISE EXCEPTION 'Student % does not fulfill the requirements set by Course %', NEW.student, NEW.course;
        END IF;

        -- Checks if student has already taken course : COMPLETED

        IF (SELECT T.grade FROM Taken AS T WHERE (T.student, T.course) = (NEW.student, NEW.course)) IN ('3', '4', '5') THEN 
            RAISE EXCEPTION 'Student % has already passed course %', NEW.student, NEW.course;
        END IF;

        --  Checks if course capacity allows a registration : COMPLETED

        IF (SELECT * FROM available_spot(NEW.course)) THEN 
            PERFORM register_student(NEW.student, NEW.course);
        ELSE
            PERFORM add_student_to_waitinglist(NEW.student, NEW.course);
        END IF;

        RETURN NEW;
    END;
$register$ LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS TRIGGER AS $unregister$
    DECLARE
        waiting_students CURSOR(wait_course TEXT) FOR SELECT student FROM CourseQueuePositions WHERE course = wait_course;
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

        RETURN OLD;
    END;
$unregister$ LANGUAGE plpgsql;


CREATE TRIGGER register INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION register();

CREATE TRIGGER unregister INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();