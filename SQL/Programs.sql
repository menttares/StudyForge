
CREATE TABLE ProgramsСourse (
  -- ID 
  id SERIAL PRIMARY KEY,
  -- Название курса
  name VARCHAR(100) NOT NULL check (LENGTH(name) >= 3),
  description VARCHAR(1000) NULL,
  id_course INTEGER REFERENCES Courses(id) ON DELETE CASCADE
);

delete from ProgramsСourse;


CREATE OR REPLACE FUNCTION create_program_course(
    p_name VARCHAR,
    p_description VARCHAR,
    p_id_course INTEGER
)
RETURNS INTEGER AS
$$
DECLARE
    new_id INTEGER;
BEGIN
    -- Проверяем, существует ли курс с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE id = p_id_course) THEN
        RETURN -1; -- Курс не найден
    END IF;

    -- Вставляем новую запись в таблицу ProgramsCourse
    INSERT INTO ProgramsСourse (name, description, id_course)
    VALUES (p_name, p_description, p_id_course)
    RETURNING id INTO new_id;

    RETURN new_id; -- Возвращаем ID созданной программы

EXCEPTION
    WHEN others THEN
        RETURN 0; -- Произошла ошибка
END;
$$
LANGUAGE PLPGSQL;

select * from create_program_course('test','нЕЕТ!', 3);



CREATE OR REPLACE FUNCTION get_programs_by_course_id(p_course_id INTEGER)
RETURNS TABLE (
    id INTEGER,
    name VARCHAR,
    description VARCHAR,
    id_course INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg.id,
        pg.name,
        pg.description,
        pg.id_course
    FROM 
        ProgramsСourse pg
    WHERE 
        pg.id_course = p_course_id;
END;
$$ LANGUAGE PLPGSQL;


select * from get_programs_by_course_id(3);



CREATE OR REPLACE FUNCTION update_program_course(
    p_id INTEGER,
    p_name VARCHAR(255),
    p_description VARCHAR(255)
) 
RETURNS BOOLEAN AS
$$
DECLARE
    success BOOLEAN := FALSE;
BEGIN
    BEGIN
        UPDATE ProgramsСourse
        SET 
            name = p_name,
            description = p_description
        WHERE 
            id = p_id;
            
        GET DIAGNOSTICS success = ROW_COUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

    RETURN success;
END;
$$
LANGUAGE PLPGSQL;



select * from update_program_course(4, null,'');
