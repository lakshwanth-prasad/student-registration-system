/*
PACKAGE DECLARATIONS
**/
CREATE OR REPLACE PACKAGE STUREG AS
    TYPE REF_CURSOR IS REF CURSOR;

    PROCEDURE SHOW_CLASS_STUDENTS(CLASSID IN CLASSES.CLASSID%TYPE, CURSOR_OUTPUT OUT REF_CURSOR);
    PROCEDURE REMOVE_GRADUATE_ENROLL(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE);
    PROCEDURE REMOVE_STUDENT(B# IN STUDENTS."B#"%TYPE);
    PROCEDURE VIEW_TABLES (tableName IN VARCHAR2,refCursor OUT sys_refcursor );
    PROCEDURE ENROLL_GRADSTU(p_classid IN g_enrollments.CLASSID%TYPE, p_B# IN g_enrollments."G_B#"%TYPE, error_info  OUT VARCHAR);
    PROCEDURE SHOW_PREREQ(DeptCode IN PREREQUISITES.pre_dept_code%TYPE,Courseid   IN PREREQUISITES.pre_course#%TYPE,refCursor OUT sys_refcursor);
END STUREG;
/


/*
PACKAGE BODY
**/
CREATE OR REPLACE PACKAGE BODY STUREG AS


/*2.Write procedures in your package to display the tuples in each of the eight tables for this
project. As an example, you can write a procedure, say show_students, to display all students in the
students table.
**/

PROCEDURE VIEW_TABLES (
    tableName IN VARCHAR2,
    refCursor OUT sys_refcursor )
  IS 
  BEGIN
    CASE tableName
    WHEN 'STUDENTS' THEN
      OPEN refCursor FOR SELECT * FROM STUDENTS;
    WHEN 'COURSES' THEN
      OPEN refCursor FOR SELECT * FROM COURSES;
    WHEN 'COURSE_CREDIT' THEN
      OPEN refCursor FOR SELECT * FROM COURSE_CREDIT;
    WHEN 'CLASSES' THEN
      OPEN refCursor FOR SELECT * FROM CLASSES;
    WHEN 'G_ENROLLMENTS' THEN
      OPEN refCursor FOR SELECT * FROM G_ENROLLMENTS;
    WHEN 'SCORE_GRADE' THEN
      OPEN refCursor FOR SELECT * FROM SCORE_GRADE;
    WHEN 'PREREQUISITES' THEN
      OPEN refCursor FOR SELECT * FROM PREREQUISITES;
    WHEN 'LOGS' THEN
      OPEN refCursor FOR SELECT * FROM LOGS;
    END CASE;
  END VIEW_TABLES;

  /*3. (3 points) Write a procedure in your package that, for a given class (with classid provided as an in
parameter), will list the B#, the first name and last name of every student in the class. If the provided
classid is invalid (i.e., not in the Classes table), report “The classid is invalid.” 
**/

  PROCEDURE SHOW_PREREQ(
      DeptCode IN PREREQUISITES.pre_dept_code%TYPE,
      Courseid   IN PREREQUISITES.pre_course#%TYPE,
      refCursor OUT sys_refcursor)
  IS
  courseDoesntExistException EXCEPTION;
  BEGIN
    OPEN refCursor FOR SELECT (pre_dept_code || pre_course#) as courses FROM PREREQUISITES START WITH dept_code=DeptCode AND course#=Courseid CONNECT BY PRIOR pre_dept_code = dept_code AND PRIOR pre_course# = course#;
	EXCEPTION
  WHEN courseDoesntExistException THEN
    RAISE_APPLICATION_ERROR(-20000, 'dept_code || course# does not exist');
  END SHOW_PREREQ;

    /*4. (4 points) Write a procedure in your package that, for a given course (with dept_code and course# as
parameters), can return all its prerequisite courses (show dept_code and course# together as in CS532),
including both direct and indirect prerequisite courses. If course C1 has course C2 as a prerequisite,
C2 is a direct prerequisite of C1. If C2 has course C3 as a direct prerequisite and C3 is not a direct
prerequisite of CS, then C3 is an indirect prerequisite for C1. Please note that indirect prerequisites
can be more than two levels away. If the provided (dept_code, course#) is invalid, report “dept_code
|| course# does not exist.” – show dept_code and course# together as in CS532. 
**/

    PROCEDURE SHOW_CLASS_STUDENTS(CLASSID IN CLASSES.CLASSID%TYPE, CURSOR_OUTPUT OUT REF_CURSOR) IS
        CLASS_COUNT NUMBER;
    BEGIN
        SELECT COUNT(*) INTO CLASS_COUNT FROM CLASSES c WHERE c.CLASSID = SHOW_CLASS_STUDENTS.CLASSID;
        IF CLASS_COUNT = 0 THEN
            raise_application_error(-20001, 'The classid: ' || SHOW_CLASS_STUDENTS.CLASSID || ' is invalid.');
        END IF;

        OPEN CURSOR_OUTPUT FOR
            SELECT s."B#", s.FIRST_NAME, s.LAST_NAME
            FROM G_ENROLLMENTS ge
                     INNER JOIN STUDENTS s ON ge."G_B#" = s."B#"
            WHERE ge.CLASSID = SHOW_CLASS_STUDENTS.CLASSID;
    END SHOW_CLASS_STUDENTS;


    /*5. (14 points) Write a procedure in your package to enroll a graduate student into a class (i.e., insert a
tuple into the G_Enrollments table). The B# of the student and the classid of the class are provided as
parameters (all new enrollments will have a null value for score). If the B# is not in the Students table,
report “The B# is invalid.” If the B# does not correspond to a graduate student, report “This is not a
graduate student.” If the classid is not in the classes table, report “The classid is invalid.” If the class
is not offered in the current semester (suppose Spring 2021 is the current semester), reject the
enrollment and report “Cannot enroll into a class from a previous semester.” If the class is already full
before the enrollment request, reject the enrollment request and report “The class is already full.” If
the student is already in the class, report “The student is already in the class.” If the student is already
enrolled in five other classes in the same semester and the same year, report “Students cannot be
enrolled in more than five classes in the same semester.” and reject the enrollment. If the student has
not completed the required prerequisite courses with at least a grade C, reject the enrollment and report
“Prerequisite not satisfied.” For all the other cases, the requested enrollment should be carried out
successfully. You need to make sure that all data are consistent after each enrollment. For example,
after you successfully enrolled a student into a class, the class size of the class should be increased by
1. Use trigger(s) to implement the updates of values caused by successfully enrolling a student into a
class. (It is recommended that all triggers for this project be implemented outside of the package.)
**/

PROCEDURE ENROLL_GRADSTU(p_classid IN g_enrollments.CLASSID%TYPE, p_B# IN g_enrollments."G_B#"%TYPE, error_info  OUT VARCHAR) IS     
        
        v_count_cl NUMBER;
        v_count_in NUMBER;
        v_count_c_s NUMBER;
        v_count_s_st NUMBER;
        v_count_f NUMBER;
        v_count NUMBER;
        v_count_c NUMBER;
        v_count_b NUMBER;
    
    BEGIN SELECT COUNT(*) INTO v_count_c FROM classes cl WHERE cl.CLASSID = p_classid;
          SELECT COUNT(*) INTO v_count_b FROM students st WHERE st."B#" = p_B#;
          SELECT COUNT(*) INTO v_count_s_st FROM students st WHERE st."B#" = p_B# AND (st.ST_LEVEL = 'PhD' OR st.ST_LEVEL = 'master');          
          SELECT COUNT(*) INTO v_count_f FROM g_enrollments g_e, classes cl WHERE g_e.CLASSID = cl.CLASSID AND g_e."G_B#" = p_B# AND cl."YEAR" = 2021 AND cl.SEMESTER = 'Spring';
          SELECT LIMIT-class_size INTO v_count_cl FROM classes WHERE classid =p_classid;
          SELECT COUNT(*) INTO v_count_in FROM g_enrollments g_e WHERE g_e.CLASSID = p_classid AND g_e."G_B#" = p_B#;
          -- Check prerequisites not satisfied by the student with a grade of 'C' or better.
          SELECT COUNT(*)
          INTO v_count
          FROM prerequisites p
          JOIN classes cl ON cl."COURSE#" = p."COURSE#"
          WHERE cl.CLASSID = p_classid
          AND p."PRE_COURSE#" NOT IN (
          SELECT c."COURSE#"
          FROM g_enrollments ge
          JOIN classes c ON ge.CLASSID = c.CLASSID
          JOIN score_grade sg ON ge.SCORE = sg.SCORE
          WHERE ge."G_B#" = p_B#
          AND sg.LGRADE IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C'));
          SELECT COUNT(*) INTO v_count_c_s FROM classes WHERE classid = p_classid AND semester = 'Spring' AND year = 2021;
          if v_count_b = 0 THEN
            error_info := 'The B# is invalid.';
      
      ELSIF v_count_s_st = 0 THEN
            error_info := 'This is not a graduate student.';

      ELSIF v_count != 0 THEN
            error_info := 'Prerequisite not satisfied.';
      
      ELSIF v_count_c = 0  THEN
            error_info := 'The classid is invalid.';
   
      ELSIF v_count_c_s = 0 THEN
            error_info := 'Cannot enroll into a class from a previous semester.';
  
      ELSIF v_count_cl = 0 THEN
           error_info := 'The class is already full.';
     
      ELSIF v_count_in != 0 THEN
           error_info := 'The student is already in the class.';
      
      
      ELSIF v_count_c = 0  THEN
            error_info := 'The classid is invalid.';
     
      ELSIF v_count_f > 4 THEN
           error_info := 'Students cannot be enrolled in more than five classes in the same semester.';

      ELSE
         INSERT INTO g_enrollments VALUES (p_B#, p_classid, NULL);
        error_info := 'Student successfully enrolled in a graduate class.';
        
      end if;

end ENROLL_GRADSTU;


  /*6. (10 points) Write a procedure in your package to drop a graduate student from a class (i.e., delete a
tuple from the G_Enrollments table). The B# of the student and the classid of the class are provided
as parameters. If the student is not in the Students table, report “The B# is invalid.” If the B# does not
correspond to a graduate student, report “This is not a graduate student.” If the classid is not in the
Classes table, report “The classid is invalid.” If the student is not enrolled in the class, report “The
student is not enrolled in the class.” If the class is not offered in Spring 2021, reject the drop attempt
and report “Only enrollment in the current semester can be dropped.” . If the class is the last class for
the student in Spring 2021, reject the drop request and report “This is the only class for this student in
Spring 2021 and cannot be dropped.” In all the other cases, the student will be dropped from the class.
Again, you should make sure that all data are consistent after a successful enrollment drop and all
updates caused by the drop need to be implemented using trigger(s). 
**/

    PROCEDURE REMOVE_GRADUATE_ENROLL(B# IN G_ENROLLMENTS."G_B#"%TYPE, CLASSID IN G_ENROLLMENTS.CLASSID%TYPE) IS
        STUDENT_COUNT NUMBER;
        GRAD_COUNT    NUMBER;
        CLASS_COUNT   NUMBER;
        IN_CLASS      NUMBER;
        CURRENT_COUNT NUMBER;
        LAST_COUNT    NUMBER;
    BEGIN
        SELECT COUNT(*) INTO STUDENT_COUNT FROM STUDENTS WHERE "B#" = B#;
        IF STUDENT_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'The student B#:' || B# || ' is invalid.');
        END IF;

        SELECT COUNT(*) INTO GRAD_COUNT FROM STUDENTS WHERE "B#" = B# AND (ST_LEVEL = 'master' OR ST_LEVEL = 'PhD');
        IF GRAD_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'The student with B#: ' || B# || ' is not a graduate student.');
        END IF;

        SELECT COUNT(*) INTO CLASS_COUNT FROM CLASSES WHERE CLASSID = CLASSID;
        IF CLASS_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'The classid: ' || CLASSID || ' is invalid.');
        END IF;

        SELECT COUNT(*) INTO IN_CLASS FROM G_ENROLLMENTS WHERE CLASSID = CLASSID AND "G_B#" = B#;
        IF IN_CLASS = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'The student with B#:' || B# || ' is not in the class:' || CLASSID || '.');
        END IF;

        SELECT COUNT(*) INTO CURRENT_COUNT FROM G_ENROLLMENTS WHERE CLASSID = CLASSID AND "G_B#" = B#;
        IF CURRENT_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Only enrollment in the current semester can be dropped.');
        END IF;

        SELECT COUNT(*) INTO LAST_COUNT FROM G_ENROLLMENTS WHERE "G_B#" = B#;
        IF LAST_COUNT = 1 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Student with B#:' || B# || ' cannot be dropped from class:' || CLASSID || '. This is the only class for this student in the current semester.');
        END IF;

        DELETE FROM G_ENROLLMENTS WHERE "G_B#" = B# AND CLASSID = CLASSID;
    END REMOVE_GRADUATE_ENROLL;

  /*7. (5 points) Write a procedure in your package to delete a student from the Students table based on a
given B# (as a parameter). If the student is not in the Students table, report “The B# is invalid.” When
a student is deleted, all tuples in the G_Enrollments table involving the student should also be deleted
(use a trigger to implement this). Note that such a deletion may trigger a number of actions as
described in the above item (item 6).
  **/

    PROCEDURE REMOVE_STUDENT(B# IN STUDENTS."B#"%TYPE) IS
        STUDENT_COUNT NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO
            STUDENT_COUNT
        FROM STUDENTS s
        WHERE s."B#" = REMOVE_STUDENT.B#;
        IF STUDENT_COUNT = 0 THEN
            raise_application_error(-20003, 'The ' || REMOVE_STUDENT.B# || ' is invalid.');
        END IF;

        DELETE FROM STUDENTS s WHERE s."B#" = REMOVE_STUDENT.B#;

    END REMOVE_STUDENT;


END STUREG;
/
