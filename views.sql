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
