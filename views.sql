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

-- CREATE VIEW StudentMandatoryProgramCourses AS (SELECT idnr AS student, course FROM Students AS S JOIN 
--     MandatoryProgram AS M ON S.program = M.program);

-- CREATE VIEW StudentMandatoryBranchCourses AS (SELECT student, course FROM StudentBranches AS SB JOIN
--     MandatoryBranch AS MB ON (SB.branch, SB.program) = (MB.branch, MB.program));

-- CREATE VIEW StudentMandatoryCourses AS (SELECT student, course FROM StudentMandatoryBranchCourses 
--     UNION SELECT student, course FROM StudentMandatoryProgramCourses);

CREATE VIEW UnreadMandatory AS (
    WITH 
        StudentMandatoryProgramCourses AS (
            SELECT idnr AS student, course FROM Students AS S JOIN 
            MandatoryProgram AS M ON S.program = M.program
        ), StudentMandatoryBranchCourses AS (
            SELECT student, course FROM StudentBranches AS SB JOIN
            MandatoryBranch AS MB ON (SB.branch, SB.program) = (MB.branch, MB.program)
        ), StudentMandatoryCourses AS (
            SELECT student, course FROM StudentMandatoryBranchCourses 
            UNION SELECT student, course FROM StudentMandatoryProgramCourses
        )
    SELECT student, course FROM StudentMandatoryCourses 
    WHERE (student, course) NOT IN (SELECT student, course FROM PassedCourses)
);

-- 6

/*

CREATE VIEW TotalCredits AS (SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student);

CREATE VIEW MandatoryLeft AS (SELECT student, COUNT(course) AS mandatoryLeft FROM UnreadMandatory GROUP BY student);

CREATE VIEW MathCredits AS (SELECT student, SUM(credits) AS mathCredits FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'math'
    GROUP BY student);

CREATE VIEW ResearchCredits AS (SELECT student, SUM(credits) AS researchCredits FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'research'
    GROUP BY student);

CREATE VIEW SeminarCourses AS (SELECT student, COUNT(C.course) AS seminarCourses FROM 
    PassedCourses AS PC JOIN Classified AS C ON PC.course = C.course
    WHERE classification = 'seminar'
    GROUP BY student);

CREATE VIEW RecommendedCourses AS (SELECT student, course, credits AS recommendedCredits FROM
    StudentBranches AS SB JOIN RecommendedBranch AS RB ON (SB.branch, SB.program) = (RB.branch, RB.program)
    JOIN Courses AS C ON course = code);

CREATE VIEW RecommendedCredits AS (SELECT RC.student, SUM(RC.recommendedCredits) AS RecommendedCredits FROM
    RecommendedCourses AS RC
    JOIN Taken AS T ON (RC.student, RC.course) = (T.student, T.course)
    WHERE grade != 'U'
    GROUP BY RC.student);

*/

CREATE VIEW StudentQualificationInfo AS (
    WITH
        MandatoryLeft AS (
            SELECT student, COUNT(course) AS mandatoryLeft FROM UnreadMandatory GROUP BY student
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
            SELECT student, course, credits AS recommendedCredits FROM StudentBranches AS SB JOIN RecommendedBranch AS RB
            ON (SB.branch, SB.program) = (RB.branch, RB.program) JOIN Courses AS C ON course = code
        ), RecommendedCredits AS (
            SELECT RC.student, SUM(RC.recommendedCredits) AS RecommendedCredits FROM RecommendedCourses AS RC
            JOIN Taken AS T ON (RC.student, RC.course) = (T.student, T.course) WHERE grade != 'U' GROUP BY RC.student
        )

    SELECT BI.student, COALESCE(mandatoryLeft, 0) AS mandatoryLeft, 
    COALESCE(recommendedCredits, 0) AS recommendedCredits, COALESCE(mathCredits, 0) AS mathCredits, 
    COALESCE(researchCredits, 0) AS researchCredits, COALESCE(seminarCourses, 0) AS seminarCourses FROM
    (SELECT idnr AS student FROM BasicInformation) AS BI FULL OUTER JOIN MandatoryLeft ON (BI.student = MandatoryLeft.student)
    FULL OUTER JOIN RecommendedCredits ON BI.student = RecommendedCredits.student
    FULL OUTER JOIN MathCredits ON BI.student = MathCredits.student
    FULL OUTER JOIN ResearchCredits ON BI.student = ResearchCredits.student
    FULL OUTER JOIN SeminarCourses ON BI.student = SeminarCourses.student
);

/*
CREATE VIEW QualifiedStudents AS (SELECT student, 
    (CASE WHEN (mandatoryLeft = 0 AND recommendedCredits >= 10 AND mathCredits >= 20 AND
        researchCredits >= 10 AND SeminarCourses >= 1) THEN TRUE ELSE FALSE END) AS qualified
    FROM StudentQualificationInfo );
*/

CREATE VIEW PathToGraduation AS (
    WITH
        TotalCredits AS (
            SELECT student, SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student
        ), QualifiedStudents AS (
            SELECT student, (
                CASE WHEN (mandatoryLeft = 0 AND recommendedCredits >= 10 AND mathCredits >= 20 AND 
                    researchCredits >= 10 AND SeminarCourses >= 1) THEN TRUE ELSE FALSE END
            ) AS qualified FROM StudentQualificationInfo
        )
    
    SELECT SQI.student, COALESCE(totalCredits, 0) AS totalCredits, mandatoryLeft,
    mathCredits, researchCredits, seminarCourses, qualified
    FROM StudentQualificationInfo AS SQI LEFT JOIN TotalCredits AS TC ON SQI.student = TC.student
    LEFT JOIN QualifiedStudents AS QI ON SQI.student = QI.student
);
