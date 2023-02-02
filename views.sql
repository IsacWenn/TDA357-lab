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
    SELECT student, course, 'registred' AS status FROM Registered);


-- 5

CREATE VIEW StudentMandatoryProgramCourses AS (SELECT idnr AS student, course FROM Students AS S JOIN 
    MandatoryProgram AS M ON S.program = M.program);

CREATE VIEW StudentMandatoryBranchCourses AS (SELECT student, course FROM StudentBranches AS SB JOIN
    MandatoryBranch AS MB ON (SB.branch, SB.program) = (MB.branch, MB.program));

CREATE VIEW StudentMandatoryCourses AS (SELECT student, course FROM StudentMandatoryBranchCourses 
    UNION SELECT student, course FROM StudentMandatoryProgramCourses);

CREATE VIEW UnreadMandatory AS (SELECT student, course FROM StudentMandatoryCourses 
    WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses));

-- 6

CREATE VIEW TotalCredits AS (SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student);
SELECT * FROM TotalCredits;

CREATE VIEW MandatoryLeft AS (SELECT student, COUNT(course) AS mandatoryLeft FROM UnreadMandatory GROUP BY student);
SELECT * FROM MandatoryLeft;

CREATE VIEW MathCredits AS (SELECT student, SUM(credits) AS mathCredits FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'math'
    GROUP BY student);
SELECT * FROM MathCredits;

CREATE VIEW ResearchCredits AS (SELECT student, SUM(credits) AS researchCredits FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'research'
    GROUP BY student);
SELECT * FROM ResearchCredits;

CREATE VIEW SeminarCourses AS (SELECT student, COUNT(C.course) AS seminarCourses FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'seminar'
    GROUP BY student);
SELECT * FROM SeminarCourses;

-- last sub-part

CREATE VIEW RecommendedCredits AS (SELECT student, SUM(credits) AS RecommendedCredits FROM
    StudentBranches AS SB JOIN RecommendedBranch AS RB ON (SB.branch, SB.program) = (RB.branch, RB.program)
    JOIN Courses AS C ON course = code AS TOT
    JOIN Taken AS T ON (TOT.student, TOT.course) = (T.student, T.course)
    WHERE grade != 'U'
    GROUP BY student);
SELECT * FROM RecommendedCredits;
/*
CREATE VIEW QualifiedStudents AS (SELECT BI.idnr AS student
    FROM BasicInformation AS BI, MathCredits AS MC, ResearchCredits AS RC, SeminarCourses AS SC
    WHERE BI.idnr == 
    --WHERE (BI.student NOT IN (SELECT MandatoryLeft.student FROM MandatoryLeft) 
    --AND true -- kommer senare
    --AND MathCredits.student >= 20
    --AND ResearchCredits.student >= 10
    --AND SeminarCourses.student >= 1
    );
SELECT * FROM QualifiedStudents;
*/

-- all mandatory
-- 10 credits of recommended from branch
-- 20 cretits of math
-- 10 credits of research
-- 1 seminar course

-- CREATE VIEW PathToGraduation AS (SELECT idnr AS student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)