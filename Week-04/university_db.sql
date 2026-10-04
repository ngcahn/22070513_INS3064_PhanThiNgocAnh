-- Name: Phan Thi Ngoc Anh
-- Student ID: 22070513
-- Assignment: Homework 4 - Introduction to MySQL
-- Date: 2026-10-04

DROP DATABASE IF EXISTS university_db;

CREATE DATABASE university_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE university_db;

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS semesters;
DROP TABLE IF EXISTS departments;

-- Stores information about university departments
CREATE TABLE departments (
    -- Primary key: unique department ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Unique department code
    code VARCHAR(10) NOT NULL UNIQUE,

    -- Unique department name
    name VARCHAR(100) NOT NULL UNIQUE,

    -- Automatically stores the creation date and time
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- Stores information about academic semesters
CREATE TABLE semesters (
    -- Primary key: unique semester ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Unique semester name
    semester_name VARCHAR(50) NOT NULL UNIQUE,

    -- Semester starting date
    start_date DATE NOT NULL,

    -- Semester ending date
    end_date DATE NOT NULL,

    -- Automatically stores the creation date and time
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- Stores information about instructors and their departments
CREATE TABLE instructors (
    -- Primary key: unique instructor ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Unique instructor code
    instructor_code VARCHAR(20) NOT NULL UNIQUE,

    -- Instructor full name
    full_name VARCHAR(100) NOT NULL,

    -- Unique instructor email
    email VARCHAR(100) NOT NULL UNIQUE,

    -- Department associated with the instructor
    department_id INT NOT NULL,

    -- Links each instructor to a department
    CONSTRAINT fk_instructor_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Stores information about students and their departments
CREATE TABLE students (
    -- Primary key: unique student ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Unique student code
    student_code VARCHAR(20) NOT NULL UNIQUE,

    -- Student full name
    full_name VARCHAR(100) NOT NULL,

    -- Unique student email
    email VARCHAR(100) NOT NULL UNIQUE,

    -- Student gender
    gender ENUM('Male', 'Female', 'Other') NOT NULL,

    -- Department associated with the student
    department_id INT NOT NULL,

    -- Links each student to a department
    CONSTRAINT fk_student_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Stores information about courses and assigned instructors
CREATE TABLE courses (
    -- Primary key: unique course ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Unique course code
    course_code VARCHAR(20) NOT NULL UNIQUE,

    -- Course name
    course_name VARCHAR(150) NOT NULL,

    -- Number of credits for the course
    credits INT NOT NULL,

    -- Department offering the course
    department_id INT NOT NULL,

    -- Instructor assigned to the course
    instructor_id INT NOT NULL,

    -- Credits must be greater than zero
    CONSTRAINT chk_course_credits
        CHECK (credits > 0),

    -- Links each course to a department
    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Links each course to an instructor
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES instructors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Stores student course enrollments and grades
CREATE TABLE enrollments (
    -- Primary key: unique enrollment ID
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Student who enrolls in the course
    student_id INT NOT NULL,

    -- Course selected by the student
    course_id INT NOT NULL,

    -- Semester in which the student takes the course
    semester_id INT NOT NULL,

    -- Grade received by the student
    grade DECIMAL(3,2) NULL,

    -- Grade must be between 0.00 and 4.00
    CONSTRAINT chk_enrollment_grade
        CHECK (
            grade IS NULL
            OR (grade >= 0.00 AND grade <= 4.00)
        ),

    -- Links the enrollment to a student
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Links the enrollment to a course
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Links the enrollment to a semester
    CONSTRAINT fk_enrollment_semester
        FOREIGN KEY (semester_id)
        REFERENCES semesters(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Prevents duplicate enrollment for the same student, course, and semester
    CONSTRAINT unique_enrollment
        UNIQUE (student_id, course_id, semester_id)
) ENGINE=InnoDB;


-- Inserts university departments
INSERT INTO departments (code, name)
VALUES
('MIS', 'Management Information Systems'),
('IT', 'Information Technology'),
('FIN', 'Finance'),
('ACC', 'Accounting'),
('BUS', 'Business Administration');


-- Inserts academic semesters
INSERT INTO semesters (semester_name, start_date, end_date)
VALUES
('Semester 1 2024-2025', '2024-09-01', '2025-01-15'),
('Semester 2 2024-2025', '2025-02-01', '2025-06-15'),
('Semester 1 2025-2026', '2025-09-01', '2026-01-15'),
('Semester 2 2025-2026', '2026-02-01', '2026-06-15'),
('Semester 1 2026-2027', '2026-09-01', '2027-01-15');


-- Inserts instructors
INSERT INTO instructors
(instructor_code, full_name, email, department_id)
VALUES
('INS001', 'Nguyen Van An', 'an.nguyen@university.edu', 1),
('INS002', 'Tran Thi Lan', 'lan.tran@university.edu', 2),
('INS003', 'Le Quang Minh', 'minh.le@university.edu', 3),
('INS004', 'Pham Thi Hoa', 'hoa.pham@university.edu', 4),
('INS005', 'Hoang Van Nam', 'nam.hoang@university.edu', 5);


-- Inserts students
INSERT INTO students
(student_code, full_name, email, gender, department_id)
VALUES
('SV001', 'Nguyen Ngoc Anh', 'ngocanh001@student.edu', 'Female', 1),
('SV002', 'Tran Minh Duc', 'minhduc002@student.edu', 'Male', 2),
('SV003', 'Le Thu Ha', 'thuha003@student.edu', 'Female', 3),
('SV004', 'Pham Quang Huy', 'quanghuy004@student.edu', 'Male', 4),
('SV005', 'Doan Mai Linh', 'mailinh005@student.edu', 'Female', 5);


-- Inserts courses
INSERT INTO courses
(course_code, course_name, credits, department_id, instructor_id)
VALUES
('MIS301', 'Database Management', 3, 1, 1),
('IT302', 'Web Development', 3, 2, 2),
('FIN303', 'Financial Management', 3, 3, 3),
('ACC304', 'Financial Accounting', 3, 4, 4),
('BUS305', 'Business Management', 3, 5, 5);


-- Inserts student enrollments and grades
INSERT INTO enrollments
(student_id, course_id, semester_id, grade)
VALUES
(1, 1, 5, 3.75),
(1, 2, 5, 3.50),
(2, 2, 5, 3.25),
(2, 3, 5, 3.00),
(3, 3, 5, 3.80),
(3, 4, 5, 3.60),
(4, 4, 5, 3.40),
(4, 5, 5, 3.20),
(5, 5, 5, 3.90),
(5, 1, 5, 3.70);


-- Displays all departments
SELECT * FROM departments;

-- Displays all semesters
SELECT * FROM semesters;

-- Displays all instructors
SELECT * FROM instructors;

-- Displays all students
SELECT * FROM students;

-- Displays all courses
SELECT * FROM courses;

-- Displays all enrollments
SELECT * FROM enrollments;


-- Displays enrollment information with related student, course, and semester names
SELECT
    students.full_name AS student,
    courses.course_name AS course,
    semesters.semester_name AS semester,
    enrollments.grade
FROM enrollments
JOIN students
    ON enrollments.student_id = students.id
JOIN courses
    ON enrollments.course_id = courses.id
JOIN semesters
    ON enrollments.semester_id = semesters.id;