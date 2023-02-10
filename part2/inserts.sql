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

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

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

INSERT INTO BranchRecommendedCourses VALUES ('CCC222', 'B1', 'Information Technology');
INSERT INTO BranchRecommendedCourses VALUES ('CCC333', 'B1', 'Information Technology');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');

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

INSERT INTO ProgramHosts VALUES('Computer Science', 'Information Technology');
INSERT INTO ProgramHosts VALUES('Architecture', 'Architecture Animal Association');
INSERT INTO ProgramHosts VALUES('Mechanical Engineering', 'Mechanical Machos');

INSERT INTO Prerequisites VALUES ('CCC555', 'CCC111');