-- Trigger to update class size after enrollment changes
CREATE OR REPLACE TRIGGER ENROLL_UPDATE
    AFTER INSERT OR DELETE
    ON G_ENROLLMENTS
    FOR EACH ROW
BEGIN
    -- If a new enrollment is inserted
    IF INSERTING THEN
        UPDATE CLASSES c
        SET c.CLASS_SIZE = c.CLASS_SIZE + 1
        WHERE c.CLASSID = :NEW.CLASSID;
    -- If an enrollment is deleted
    ELSIF DELETING THEN
        UPDATE CLASSES c
        SET c.CLASS_SIZE = c.CLASS_SIZE - 1
        WHERE c.CLASSID = :OLD.CLASSID;
    END IF;
END;
/

-- Disable the ENROLL_UPDATE trigger
ALTER TRIGGER ENROLL_UPDATE DISABLE;

-- Trigger to delete corresponding enrollments when a student is deleted
CREATE OR REPLACE TRIGGER STUDEL
    BEFORE DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    DELETE
    FROM G_ENROLLMENTS ge
    WHERE ge."G_B#" = :OLD.B#;
END;
/

-- Trigger to log student deletions
CREATE OR REPLACE TRIGGER STULOG
    AFTER DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    -- Insert deletion details into LOGS table
    INSERT INTO LOGS
    VALUES (log_sequence.NEXTVAL, (SELECT USER FROM dual), CURRENT_TIMESTAMP, 'STUDENTS', 'DELETE', :OLD.B#);
END;
/

-- Trigger to log enrollment changes
CREATE OR REPLACE TRIGGER ENROLL_LOG
    AFTER INSERT OR DELETE
    ON G_ENROLLMENTS
    FOR EACH ROW
BEGIN
    -- If a new enrollment is inserted
    IF INSERTING THEN
        -- Insert insertion details into LOGS table
        INSERT INTO LOGS
        VALUES (log_sequence.NEXTVAL, (SELECT USER FROM dual), CURRENT_TIMESTAMP, 'G_ENROLLMENTS', 'INSERT',
                TO_CHAR(:NEW.G_B#) || ',' || TO_CHAR(:NEW.CLASSID));
    -- If an enrollment is deleted
    ELSIF DELETING THEN
        -- Insert deletion details into LOGS table
        INSERT INTO LOGS
        VALUES (log_sequence.NEXTVAL, (SELECT USER FROM dual), CURRENT_TIMESTAMP, 'G_ENROLLMENTS', 'DELETE',
                TO_CHAR(:OLD.G_B#) || ',' || TO_CHAR(:OLD.CLASSID));
    END IF;
END;
/
