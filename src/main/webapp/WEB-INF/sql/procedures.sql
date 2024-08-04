CREATE OR REPLACE PACKAGE SRS AS

    TYPE REF_CURSOR IS REF CURSOR;

    PROCEDURE SHOW_CLASSES(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_COURSES(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_COURSE_CREDIT(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_G_ENROLLMENTS(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_LOGS(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_PREREQUISITES(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_SCORE_GRADE(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE SHOW_STUDENTS(CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE LIST_CLASS(CLASSID IN CLASSES.CLASSID%TYPE, CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE get_prerequisite_courses(COURSE# IN PREREQUISITES."COURSE#"%TYPE, DEPT_CODE IN PREREQUISITES.DEPT_CODE%TYPE, CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE ENROLL_GRAD(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE);
    PROCEDURE DROP_GRAD(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE);
    PROCEDURE DEL_STUDENT(B# IN STUDENTS."B#"%TYPE);

END SRS;^

CREATE OR REPLACE PACKAGE BODY SRS AS

    /*
    2.  (4 points) Write procedures in your package to display the tuples in each of the eight tables for thAS
        project. As an example, you can write a procedure, say show_students, to display all students in tAS
        students table.
    **/

    PROCEDURE SHOW_CLASSES(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM CLASSES;
    END SHOW_CLASSES;

    PROCEDURE SHOW_COURSES(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM COURSES;
    END SHOW_COURSES;


    PROCEDURE SHOW_COURSE_CREDIT(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM COURSE_CREDIT;
    END SHOW_COURSE_CREDIT;


    PROCEDURE SHOW_G_ENROLLMENTS(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM G_ENROLLMENTS;
    END SHOW_G_ENROLLMENTS;


    PROCEDURE SHOW_LOGS(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM LOGS;
    END SHOW_LOGS;


    PROCEDURE SHOW_PREREQUISITES(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM prerequisites;
    END SHOW_PREREQUISITES;


    PROCEDURE SHOW_SCORE_GRADE(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM SCORE_GRADE;
    END SHOW_SCORE_GRADE;


    PROCEDURE SHOW_STUDENTS(CURSOR_OUTPUT OUT REF_CURSOR) IS
    BEGIN
        OPEN CURSOR_OUTPUT FOR
            SELECT * FROM STUDENTS;
    END SHOW_STUDENTS;


/*
3.  (3 points) Write a procedure in your package that, for a given class (with classid provided as an AS
    parameter), will list the B#, the first name and last name of every student in the class. If the provided
    classid is invalid (i.e., not in the Classes table), report “The classid is invalid.”
**/

    PROCEDURE LIST_CLASS(CLASSID IN CLASSES.CLASSID%TYPE, CURSOR_OUTPUT OUT REF_CURSOR) IS
        CLASS_COUNT NUMBER;
    BEGIN
        SELECT COUNT(*) INTO CLASS_COUNT FROM CLASSES c WHERE c.CLASSID = LIST_CLASS.CLASSID;
        IF CLASS_COUNT = 0 THEN
            raise_application_error(-20001, 'The classid: ' || LIST_CLASS.CLASSID || ' is invalid.');
        END IF;

        OPEN CURSOR_OUTPUT FOR
            SELECT s."B#", s.FIRST_NAME, s.LAST_NAME
            FROM G_ENROLLMENTS ge
                     INNER JOIN STUDENTS s ON ge."G_B#" = s."B#"
            WHERE ge.CLASSID = LIST_CLASS.CLASSID;
    END LIST_CLASS;


/*
4.  (4 points) Write a procedure in your package that, for a given course (with dept_code and course# AS
    parameters), can return all its prerequisite courses (show dept_code and course# together as in
    CS532), including both direct and indirect prerequisite courses. If course C1 has course C2 as a
    prerequisite, C2 is a direct prerequisite of C1. If C2 has course C3 as a direct prerequisite and C3 is
    not a direct prerequisite of CS, then C3 is an indirect prerequisite for C1. Please note that indirect
    prerequisites can be more than two levels away. If the provided (dept_code, course#) is invalid,
    report “dept_code || course# does not exist.” – show dept_code and course# together as in CS532.
 **/

    PROCEDURE get_prerequisite_courses(COURSE# IN PREREQUISITES."COURSE#"%TYPE, DEPT_CODE IN PREREQUISITES.DEPT_CODE%TYPE,
                                       CURSOR_OUTPUT OUT REF_CURSOR) IS
        COURSE_COUNT NUMBER;
    BEGIN
        SELECT COUNT(*) INTO COURSE_COUNT FROM COURSES c WHERE c.DEPT_CODE = get_prerequisite_courses.DEPT_CODE AND c."COURSE#" = get_prerequisite_courses.COURSE#;
        IF COURSE_COUNT = 0 THEN
            raise_application_error(-20002, get_prerequisite_courses.DEPT_CODE || get_prerequisite_courses.COURSE# || ' does not exist.');
        END IF;
        OPEN CURSOR_OUTPUT FOR
            SELECT x.preq
            FROM (SELECT CONNECT_BY_ROOT cp.course c, cp.preq preq
                  FROM (SELECT p.DEPT_CODE || p."COURSE#" course, p.PRE_DEPT_CODE || p."PRE_COURSE#" preq
                        FROM PREREQUISITES p) cp
                  CONNECT BY PRIOR cp.preq = cp.course) x
            WHERE x.c = get_prerequisite_courses.DEPT_CODE || get_prerequisite_courses.COURSE#;
    END get_prerequisite_courses;


/*
5.  (14 points) Write a procedure in your package to enroll a graduate student into a class (i.e., insertAS
    tuple into the G_Enrollments table). The B# of the student and the classid of the class are provided
    as parameters (all new enrollments will have a null value for score). If the B# is not in the Students
    table, report “The B# is invalid.” If the B# does not correspond to a graduate student, report “This is
    not a graduate student.” If the classid is not in the classes table, report “The classid is invalid.” If the
    class is not offered in the current semester (suppose Spring 2021 is the current semester), reject the
    enrollment and report “Cannot enroll into a class from a previous semester.” If the class is already
    full before the enrollment request, reject the enrollment request and report “The class is already
    full.”If the student is already in the class, report “The student is already in the class.” If the student
    is already enrolled in five other classes in the same semester and the same year, report “Students
    cannot be enrolled in more than five classes in the same semester.” and reject the enrollment. If the
    student has not completed the required prerequisite courses with at least a grade C, reject the
    enrollment and report “Prerequisite not satisfied.” For all the other cases, the requested enrollment
    should be carried out successfully. You need to make sure that all data are consistent after each
    enrollment. For example, after you successfully enrolled a student into a class, the class size of the
    class should be increased by 1. Use trigger(s) to implement the updates of values caused by
    successfully enrolling a student into a class. (It is recommended that all triggers for this project be
    implemented outside of the package.)
 */

    PROCEDURE ENROLL_GRAD(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE) IS
        STUDENT_COUNT NUMBER;
        GRAD_COUNT    NUMBER;
        CLASS_COUNT   NUMBER;
        CURRENT_SEM   NUMBER;
        CLASS_SIZE    NUMBER;
        CLASS_LIMIT   NUMBER;
        IN_CLASS      NUMBER;
        CURRENT_COUNT NUMBER;
        PRE_REQ_COUNT NUMBER;
        PRE_REQ_MET   NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO
            STUDENT_COUNT
        FROM STUDENTS s
        WHERE s."B#" = ENROLL_GRAD.B#;
        IF STUDENT_COUNT = 0 THEN
            raise_application_error(-20003, 'The student with B#: ' || ENROLL_GRAD.B# || ' is invalid.');
        END IF;

        SELECT COUNT(*)
        INTO
            GRAD_COUNT
        FROM STUDENTS s
        WHERE s."B#" = ENROLL_GRAD.B#
          AND (s.ST_LEVEL = 'master'
            OR s.ST_LEVEL = 'PhD');
        IF GRAD_COUNT = 0 THEN
            raise_application_error(-20004, 'The student with B#: ' || ENROLL_GRAD.B# || ' is not a graduate student.');
        END IF;

        SELECT count(*)
        INTO CLASS_COUNT
        FROM CLASSES c
        WHERE c.CLASSID = ENROLL_GRAD.CLASSID;
        IF CLASS_COUNT = 0 THEN
            raise_application_error(-20001, 'The classid: ' || ENROLL_GRAD.CLASSID || 'is invalid.');
        END IF;

        SELECT COUNT(*)
        INTO CURRENT_SEM
        FROM CLASSES c
                 INNER JOIN CUR_SEM cs on c.YEAR = cs.YEAR and c.SEMESTER = cs.SEMESTER
        WHERE c.CLASSID = ENROLL_GRAD.CLASSID;

        IF CURRENT_SEM = 0 THEN
            raise_application_error(-20005, 'Cannot enroll into a class:' || ENROLL_GRAD.CLASSID || ' from a previous semester.');
        END IF;

        SELECT c.CLASS_SIZE,
               c."LIMIT"
        INTO CLASS_SIZE,
            CLASS_LIMIT
        FROM CLASSES c
        WHERE c.CLASSID = ENROLL_GRAD.CLASSID;

        IF CLASS_SIZE = CLASS_LIMIT THEN
            raise_application_error(-20006, 'The class:' || ENROLL_GRAD.CLASSID || ' is already full.');
        END IF;

        SELECT count(*)
        INTO IN_CLASS
        FROM G_ENROLLMENTS ge
        WHERE ge.CLASSID = ENROLL_GRAD.CLASSID
          AND ge."G_B#" = ENROLL_GRAD.B#;
        IF IN_CLASS != 0 THEN
            raise_application_error(-20007, 'The student with B#:' || ENROLL_GRAD.B# || ' is already in the class:' || ENROLL_GRAD.CLASSID || '.');
        END IF;

        SELECT count(*)
        INTO CURRENT_COUNT
        FROM G_ENROLLMENTS ge,
             CLASSES c,
             CUR_SEM cs
        WHERE ge."G_B#" = ENROLL_GRAD.B#
          AND ge.CLASSID = c.CLASSID
          AND c."YEAR" = cs."YEAR"
          AND c.SEMESTER = cs.SEMESTER;
        IF CURRENT_COUNT > 4 THEN
            raise_application_error(-20008, 'Student with B#:' || ENROLL_GRAD.B# || ' cannot be enrolled in the class:' || ENROLL_GRAD.CLASSID ||
                                            '.Cannot be enrolled in more than five classes in the same semester.');
        END IF;

        SELECT COUNT(*)
        INTO PRE_REQ_COUNT
        FROM CLASSES
        INNER JOIN PREREQUISITES P on CLASSES.DEPT_CODE = P.DEPT_CODE and CLASSES.COURSE# = P.COURSE#
        WHERE CLASSES.CLASSID = ENROLL_GRAD.CLASSID;

        IF PRE_REQ_COUNT > 0 THEN
            SELECT COUNT(*)
            INTO PRE_REQ_MET
            FROM CLASSES
            INNER JOIN PREREQUISITES P on CLASSES.DEPT_CODE = P.DEPT_CODE and CLASSES.COURSE# = P.COURSE#
            WHERE CLASSES.CLASSID = ENROLL_GRAD.CLASSID AND CONCAT(P.PRE_DEPT_CODE, P.PRE_COURSE#) IN (
                SELECT CONCAT(C2.DEPT_CODE, C2.COURSE#) FROM G_ENROLLMENTS GE
                                                                 LEFT JOIN SCORE_GRADE SG on SG.SCORE = GE.SCORE
                                                                 JOIN CLASSES C2 on C2.CLASSID = GE.CLASSID
                WHERE sg.LGRADE IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') AND G_B# = ENROLL_GRAD.B#
            );

            IF PRE_REQ_MET = 0 THEN
                raise_application_error(-20009, 'Student with B#:' || ENROLL_GRAD.B# || ' cannot be enrolled in the class:' || ENROLL_GRAD.CLASSID ||
                                                '. Prerequisite not satisfied.');
            END IF;

        END IF;

        INSERT INTO G_ENROLLMENTS VALUES (ENROLL_GRAD.B#, ENROLL_GRAD.CLASSID, NULL);

    END ENROLL_GRAD;

/*
6.  (10 points) Write a procedure in your package to drop a graduate student from a class (i.e., delete a
    tuple from the G_Enrollments table). The B# of the student and the classid of the class are provided
    as parameters. If the student is not in the Students table, report “The B# is invalid.” If the B# does
    not correspond to a graduate student, report “This is not a graduate student.” If the classid is not in
    the Classes table, report “The classid is invalid.” If the student is not enrolled in the class, report
    “The student is not enrolled in the class.” If the class is not offered in Spring 2021, reject the drop
    attempt and report “Only enrollment in the current semester can be dropped.”. If the class is the last
    class for the student in Spring 2021, reject the drop request and report “This is the only class for this
    student in Spring 2021 and cannot be dropped.” In all the other cases, the student will be dropped
    from the class. Again, you should make sure that all data are consistent after a successful enrollment
    drop and all updates caused by the drop need to be implemented using trigger(s).
 */

    PROCEDURE DROP_GRAD(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE) IS
        STUDENT_COUNT NUMBER;
        GRAD_COUNT    NUMBER;
        CLASS_COUNT   NUMBER;
        IN_CLASS      NUMBER;
        CURRENT_COUNT NUMBER;
        LAST_COUNT    NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO
            STUDENT_COUNT
        FROM STUDENTS s
        WHERE s."B#" = DROP_GRAD.B#;
        IF STUDENT_COUNT = 0 THEN
            raise_application_error(-20003, 'The student B#:' || DROP_GRAD.B# || ' is invalid.');
        END IF;

        SELECT COUNT(*)
        INTO
            GRAD_COUNT
        FROM STUDENTS s
        WHERE s."B#" = DROP_GRAD.B#
          AND (s.ST_LEVEL = 'master'
            OR s.ST_LEVEL = 'PhD');
        IF GRAD_COUNT = 0 THEN
            raise_application_error(-20004, 'The Student With B#: ' || DROP_GRAD.B# || ' is not a graduate student.');
        END IF;

        SELECT count(*)
        INTO CLASS_COUNT
        FROM CLASSES c
        WHERE c.CLASSID = DROP_GRAD.CLASSID;
        IF CLASS_COUNT = 0 THEN
            raise_application_error(-20001, 'The classid: ' || DROP_GRAD.CLASSID || 'is invalid.');
        END IF;

        SELECT count(*)
        INTO IN_CLASS
        FROM G_ENROLLMENTS ge
        WHERE ge.CLASSID = DROP_GRAD.CLASSID
          AND ge."G_B#" = DROP_GRAD.B#;
        IF IN_CLASS = 0 THEN
            raise_application_error(-20010, 'The student with B#:' || DROP_GRAD.B# || ' is not in the class:' || DROP_GRAD.CLASSID || '.');
        END IF;

        SELECT COUNT(*)
        INTO CURRENT_COUNT
        FROM CLASSES c
                 INNER JOIN CUR_SEM cs on c.YEAR = cs.YEAR and c.SEMESTER = cs.SEMESTER
        WHERE c.CLASSID = DROP_GRAD.CLASSID;
        IF CURRENT_COUNT = 0 THEN
            raise_application_error(-20011, 'Only enrollment in the current semester can be dropped.');
        END IF;

        SELECT count(*)
        INTO LAST_COUNT
        FROM G_ENROLLMENTS ge
                 INNER JOIN CLASSES C on ge.CLASSID = C.CLASSID
                 INNER JOIN CUR_SEM CS on C.YEAR = CS.YEAR and C.SEMESTER = CS.SEMESTER
        WHERE ge."G_B#" = DROP_GRAD.B#;
        IF LAST_COUNT = 1 THEN
            raise_application_error(-20012, 'Student with B#:' || DROP_GRAD.B# || ' cannot be dropped from class:' || DROP_GRAD.CLASSID ||
                                            '.This is the only class for this student in current semester');
        END IF;

        DELETE FROM G_ENROLLMENTS ge WHERE ge."G_B#" = DROP_GRAD.B# AND ge.CLASSID = DROP_GRAD.CLASSID;

    END DROP_GRAD;


/*
7.  (5 points) Write a procedure in your package to delete a student from the Students table based on a
    given B# (as a parameter). If the student is not in the Students table, report “The B# is invalid.”
    When a student is deleted, all tuples in the G_Enrollments table involving the student should also be
    deleted (use a trigger to implement this). Note that such a deletion may trigger a number of actions
    as described in the above item (item 6).
 */
    PROCEDURE DEL_STUDENT(B# IN STUDENTS."B#"%TYPE) IS
        STUDENT_COUNT NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO
            STUDENT_COUNT
        FROM STUDENTS s
        WHERE s."B#" = DEL_STUDENT.B#;
        IF STUDENT_COUNT = 0 THEN
            raise_application_error(-20003, 'The ' || DEL_STUDENT.B# || ' is invalid.');
        END IF;

        DELETE FROM STUDENTS s WHERE s."B#" = DEL_STUDENT.B#;

    END DEL_STUDENT;

END SRS;^

CREATE OR REPLACE PROCEDURE add_course_credit(course_no IN number)
    IS
    credits_val NUMBER(1) := 0;
BEGIN
    IF course_no BETWEEN 100 AND 499 THEN
        credits_val := 4;
    ELSIF course_no BETWEEN 500 AND 799 THEN
        credits_val := 3;
    END IF;
    INSERT INTO COURSE_CREDIT VALUES (course_no, credits_val);
END;^