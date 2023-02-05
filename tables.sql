CREATE TABLE Students(
    idnr TEXT PRIMARY KEY CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)
);

CREATE TABLE Program(
    name TEXT,
    program TEXT,
    PRIMARY KEY(name, program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity > 0),
    FOREIGN KEY (code) REFERENCES Courses
);

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY CHECK (student SIMILAR TO '[0-9]{10}'),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    classification TEXT NOT NULL,
    PRIMARY KEY(course, classification),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (classification) REFERENCES Classifications
);

CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, program),
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (branch, program) REFERENCES Branches   
);

CREATE TABLE Registered(
    student TEXT NOT NULL CHECK (student SIMILAR TO '[0-9]{10}'),
    course CHAR(6) NOT NULL,
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE Taken(
    student TEXT NOT NULL CHECK (student SIMILAR TO '[0-9]{10}'),
    course CHAR(6) NOT NULL,
    grade CHAR(1) DEFAULT 'U' NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE WaitingList(
    student TEXT NOT NULL CHECK (student SIMILAR TO '[0-9]{10}'),
    course CHAR(6) NOT NULL,
    position TIMESTAMP NOT NULL,
    PRIMARY KEY(student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course) REFERENCES LimitedCourses
);