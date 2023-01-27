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

-- CREATE VIEW PathToGraduation AS (SELECT idnr AS student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)