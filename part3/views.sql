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
