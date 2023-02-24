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