--------------------------------------------------- TABLES ---------------------------------------------------

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL
);

CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL
);

CREATE TABLE Students(
    idnr TEXT PRIMARY KEY CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs,
    UNIQUE (idnr, program)
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program),
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK (credits >= 0),
    department TEXT NOT NULL,
    FOREIGN KEY (department) REFERENCES Departments
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity >= 0),
    FOREIGN KEY (code) REFERENCES Courses
);


CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

--------------------- RELATIONS ---------------------

CREATE TABLE ProgramHosts(
    department TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(department, program),
    FOREIGN KEY (department) REFERENCES Departments,
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE ProgramMandatoryCourses(
    course CHAR(6) NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (program) REFERENCES Programs
);


CREATE TABLE BranchMandatoryCourses(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE BranchRecommendedCourses(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (branch, program) REFERENCES Branches   
);

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches,
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program)

);

CREATE TABLE Taken(
    student TEXT NOT NULL,
    course CHAR(6) NOT NULL,
    grade CHAR(1) DEFAULT 'U' NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE Registered(
    student TEXT NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE WaitingList(
    student TEXT NOT NULL,
    course CHAR(6) NOT NULL,
    position TIMESTAMP NOT NULL,
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES LimitedCourses,
    UNIQUE (position, course)
);

CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    classification TEXT NOT NULL,
    PRIMARY KEY(course, classification),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (classification) REFERENCES Classifications
);

CREATE TABLE Prerequisites(
    course CHAR(6) NOT NULL,
    requirement CHAR(6) NOT NULL,
    PRIMARY KEY(course, requirement),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (requirement) REFERENCES Courses
);

--------------------------------------------------- INSERTS ---------------------------------------------------

INSERT INTO Departments VALUES ('Computer Science', 'CS');
INSERT INTO Departments VALUES ('Architecture', 'A');
INSERT INTO Departments VALUES ('Mechanical Engineering', 'ME');

INSERT INTO Programs VALUES ('Information Technology', 'IT');
INSERT INTO Programs Values ('Data Dudes', 'DD');
INSERT INTO Programs Values ('Architecture Animal Association', 'AAA');
INSERT INTO Programs Values ('Mechanical Machos', 'MM');

INSERT INTO Branches VALUES ('B1','Information Technology');
INSERT INTO Branches VALUES ('B2','Data Dudes');
INSERT INTO Branches VALUES ('B1','Mechanical Machos');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Information Technology');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Information Technology');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Data Dudes');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Mechanical Machos');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Mechanical Machos');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Architecture Animal Association');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Computer Science');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Computer Science');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Architecture');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Mechanical Engineering');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Mechanical Engineering');
INSERT INTO Courses VALUES ('TTT111','TEST1',42,'Computer Science');
INSERT INTO Courses VALUES ('TTT222','TEST2',42,'Computer Science');
INSERT INTO Courses VALUES ('TTT333','TEST3',42,'Computer Science');
INSERT INTO Courses VALUES ('TTT444','TEST4',42,'Computer Science');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',3);
INSERT INTO LimitedCourses VALUES ('TTT222', 1);
INSERT INTO LimitedCourses VALUES ('TTT333', 5);
INSERT INTO LimitedCourses VALUES ('TTT444', 1);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Information Technology');
INSERT INTO StudentBranches VALUES ('3333333333','B2','Data Dudes');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Mechanical Machos');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Mechanical Machos');

INSERT INTO ProgramMandatoryCourses VALUES ('CCC111','Information Technology');

INSERT INTO BranchMandatoryCourses VALUES ('CCC333', 'B1', 'Mechanical Machos');
INSERT INTO BranchMandatoryCourses VALUES ('CCC444', 'B1', 'Mechanical Machos');

INSERT INTO BranchRecommendedCourses VALUES ('CCC222', 'B1', 'Mechanical Machos');
INSERT INTO BranchRecommendedCourses VALUES ('CCC333', 'B1', 'Information Technology');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('3333333333','TTT333');
INSERT INTO Registered VALUES ('1111111111','TTT444');
INSERT INTO Registered VALUES ('2222222222','TTT444');
INSERT INTO Registered VALUES ('5555555555','TTT444');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222', CURRENT_TIMESTAMP);
INSERT INTO WaitingList VALUES('3333333333','CCC333', CURRENT_TIMESTAMP);
INSERT INTO WaitingList VALUES('2222222222','CCC333', CURRENT_TIMESTAMP);
INSERT INTO WaitingList VALUES('3333333333','TTT444', CURRENT_TIMESTAMP);
INSERT INTO WaitingList VALUES('2222222222','TTT222', CURRENT_TIMESTAMP);

INSERT INTO ProgramHosts VALUES('Computer Science', 'Information Technology');
INSERT INTO ProgramHosts VALUES('Architecture', 'Architecture Animal Association');
INSERT INTO ProgramHosts VALUES('Mechanical Engineering', 'Mechanical Machos');

INSERT INTO Prerequisites VALUES ('CCC555', 'CCC111');
INSERT INTO Prerequisites VALUES ('CCC555', 'CCC222');

--------------------------------------------------- VIEWS ---------------------------------------------------

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
