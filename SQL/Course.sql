-- раздел
CREATE TABLE Сategories (
  -- ID
  id SERIAL PRIMARY KEY,
  -- Название Категории
  name VARCHAR(100) UNIQUE NOT NULL
);


select * from Courses;

select * from Sections;

-- подразделы
CREATE TABLE Sections (
  -- ID
  id SERIAL PRIMARY KEY,
  -- FK ключ к разделу, к котору относится раздел
  id_category INTEGER REFERENCES Сategories(id) ON DELETE SET NULL,
  -- Название Раздела
  name VARCHAR(100) UNIQUE NOT NULL
);

CREATE OR REPLACE FUNCTION get_all_sections()
RETURNS TABLE (
    section_id INTEGER,
    section_name VARCHAR(100)
) AS
$$
BEGIN
    RETURN QUERY SELECT id, name FROM Sections;
END;
$$
LANGUAGE PLPGSQL;

select * from get_all_sections();

-- Создание таблицы курсов
CREATE TABLE Courses (
  -- ID курса
  id SERIAL PRIMARY KEY,
  -- категория, к которому относится курс
  id_Section INTEGER REFERENCES Sections(id),
  -- создатель курса
  id_Account INTEGER REFERENCES Accounts(id) ON DELETE CASCADE,
  -- Название курса
  name VARCHAR(60) NOT NULL check(
    LENGTH(name) >= 3
    and LENGTH(name) <= 60
  ),
  -- Описание курса
  description varchar(1000) NULL,
  -- Дата создания (автоматически заполняется)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- закрыт ли курс организатором?
  course_closed bool DEFAULT FALSE
	
);


CREATE VIEW CoursesPerSection AS
SELECT
    s.name AS section_name,
    COUNT(c.id) AS course_count
FROM
    Sections s
LEFT JOIN
    Courses c ON s.id = c.id_Section
GROUP BY
    s.name;

CREATE OR REPLACE FUNCTION Get_Courses_PerSection()
RETURNS setof CoursesPerSection AS $$
BEGIN
    RETURN QUERY
    SELECT
	*
    FROM
        CoursesPerSection;
END;
$$ LANGUAGE plpgsql;


select * from CoursesPerSection;

CREATE VIEW NewAccountsPerDay AS
SELECT
    DATE_TRUNC('day', created_at) AS registration_date,
    COUNT(id) AS new_account_count
FROM
    Accounts
GROUP BY
    registration_date
ORDER BY
    registration_date;

CREATE VIEW CoursesPerDay AS
SELECT
    DATE_TRUNC('day', created_at) AS creation_date,
    COUNT(id) AS course_count
FROM
    Courses
GROUP BY
    creation_date
ORDER BY
    creation_date;



CREATE TABLE BannedCourses (
  -- ID записи о забаненном курсе
  id SERIAL PRIMARY KEY,
  -- ID забаненного курса
  id_Course INTEGER REFERENCES Courses(id) ON DELETE CASCADE,
  -- ID администратора, который забанил курс
  id_Administrator INTEGER REFERENCES Accounts(id) ON DELETE SET NULL,
  -- Дата и время забана курса
  banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

insert into BannedCourses(id_Course, id_Administrator, cause) values
	(17,1,'нет причины')


CREATE OR REPLACE FUNCTION is_course_banned(p_course_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Проверка наличия записи о бане в таблице BannedCourses
    SELECT EXISTS (
        SELECT 1
        FROM BannedCourses
        WHERE id_Course = p_course_id
    ) INTO v_exists;

    -- Возвращаем результат
    RETURN v_exists;
END;
$$ LANGUAGE plpgsql;

select * from courses;
select * from BannedCourses;
select is_course_banned(17);

	
CREATE OR REPLACE FUNCTION add_ban(
    p_course_id INTEGER,
    p_admin_id INTEGER,
    p_reason TEXT
)
RETURNS INTEGER AS $$
DECLARE
    v_ban_id INTEGER;
BEGIN
    -- Вставляем новую запись в таблицу BannedCourses
    INSERT INTO BannedCourses (id_Course, id_Administrator, cause)
    VALUES (p_course_id, p_admin_id, p_reason)
    RETURNING id INTO v_ban_id;

    -- В случае успешной вставки возвращаем id записи
    RETURN v_ban_id;
EXCEPTION
    WHEN OTHERS THEN
        -- В случае ошибки возвращаем 0
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

select add_ban(17,1,'нет причины');

CREATE OR REPLACE FUNCTION delete_ban_by_course_id(p_course_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM BannedCourses WHERE id_Course = p_course_id;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;


SELECT delete_ban(1); 



-- представление всех категорий
CREATE VIEW CategorySections AS
SELECT
    c.id AS categoryId,
    c.name AS category,
    s.id AS sectionId,
    s.name AS subsection
FROM
    Сategories c
JOIN
    Sections s ON c.id = s.id_category;

select * from CategorySections;



-- проверка, что пользователь имеет право на редактирование
CREATE OR REPLACE FUNCTION can_edit_course(profile_id INTEGER, course_id INTEGER)
RETURNS BOOLEAN AS
$$
DECLARE
    is_creator BOOLEAN := FALSE;
BEGIN
    -- Проверяем, является ли указанный профиль создателем курса
    SELECT TRUE INTO is_creator
    FROM Courses
    WHERE id = course_id AND id_Account = profile_id;

    -- Если is_creator NULL, то присваиваем ему значение FALSE
    IF is_creator IS NULL THEN
        is_creator := FALSE;
    END IF;

    -- Возвращаем результат проверки
    RETURN is_creator;
END;
$$
LANGUAGE PLPGSQL;


-- функция возвращения категорий
CREATE OR REPLACE FUNCTION get_categories_with_subsections()
RETURNS TABLE (category_name VARCHAR, subsections JSONB) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS category_name,
        jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name)) AS subsections
    FROM
        Сategories c
    LEFT JOIN
        Sections s ON c.id = s.id_category
    GROUP BY
        c.id, c.name;
END;
$$
LANGUAGE PLPGSQL;

select * from get_categories_with_subsections();



CREATE OR REPLACE FUNCTION create_course(
    p_profile_id INTEGER,
    p_course_name VARCHAR,
    p_section_id INTEGER,
    p_description VARCHAR
)
RETURNS INTEGER AS
$$
DECLARE
    inserted_id INTEGER;
BEGIN
    -- Проверяем, существует ли профиль с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE id = p_profile_id) THEN
        RETURN -1; -- Профиль не найден
    END IF;

    -- Проверяем, существует ли секция с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Sections WHERE id = p_section_id) THEN
        RETURN -2; -- Секция не найдена
    END IF;

    -- Добавляем новый курс
    INSERT INTO Courses (id_Section, id_Account, name, description)
    VALUES (p_section_id, p_profile_id, p_course_name, p_description)
    RETURNING id INTO inserted_id;

    RETURN inserted_id; -- Возвращаем ID созданного курса

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        RETURN 0;
END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION update_course(
    p_course_id INTEGER,
    p_course_name VARCHAR,
    p_section_id INTEGER,
    p_description VARCHAR
)
RETURNS BOOLEAN AS
$$
BEGIN
    -- Проверяем, существует ли курс с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE id = p_course_id) THEN
        RETURN FALSE; -- Курс не найден
    END IF;

    -- Проверяем, существует ли секция с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Sections WHERE id = p_section_id) THEN
        RETURN FALSE; -- Секция не найдена
    END IF;

    -- Обновляем данные курса
    UPDATE Courses
    SET
        id_Section = p_section_id,
        name = p_course_name,
        description = p_description
    WHERE
        id = p_course_id;

    RETURN TRUE; -- Успешно обновлено

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем FALSE
        RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;

-- 
CREATE OR REPLACE FUNCTION update_course(
    p_course_id INTEGER,
    p_course_name VARCHAR,
    p_section_id INTEGER,
    p_description VARCHAR,
    p_course_closed BOOLEAN
)
RETURNS BOOLEAN AS
$$
BEGIN
    -- Проверяем, существует ли курс с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE id = p_course_id) THEN
        RETURN FALSE; -- Курс не найден
    END IF;

    -- Проверяем, существует ли секция с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Sections WHERE id = p_section_id) THEN
        RETURN FALSE; -- Секция не найдена
    END IF;

    -- Обновляем данные курса
    UPDATE Courses
    SET
        id_Section = p_section_id,
        name = p_course_name,
        description = p_description,
        course_closed = p_course_closed
    WHERE
        id = p_course_id;

    RETURN TRUE; -- Успешно обновлено

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем FALSE
        RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;


SELECT update_course(
    p_course_id := 1, -- Замените на ID курса, который вы хотите обновить
    p_course_name := 'Новое название курса',
    p_section_id := 1, -- Замените на ID секции, к которой вы хотите привязать курс
    p_description := 'Новое описание курса',
    p_course_closed := FALSE -- Замените на true/false в зависимости от того, нужно ли закрыть курс
);




CREATE OR REPLACE VIEW CourseView AS
SELECT
    c.id AS categoryId,
    c.name AS categoryName,
    s.id AS sectionId,
    s.name AS sectionName,
    cr.id AS courseId,
    cr.name AS courseName,
    cr.description AS courseDescription,
    cr.created_at AS courseCreatedAt,
    cr.course_closed AS courseClosed,
	ac.id AS accountId
FROM
    Сategories c
JOIN
    Sections s ON c.id = s.id_Category
JOIN
    Courses cr ON s.id = cr.id_Section
JOIN
    Accounts ac ON ac.id = cr.id_Account;

select * from CourseView;


CREATE OR REPLACE FUNCTION get_course_info(course_id INTEGER)
RETURNS CourseView AS
$$
DECLARE
    course_info CourseView;
BEGIN
    SELECT * INTO course_info FROM CourseView WHERE courseid = get_course_info.course_id;
    RETURN course_info;
END;
$$
LANGUAGE PLPGSQL;

select * from CourseView;
select * from get_course_info(10);

CREATE OR REPLACE FUNCTION get_courses_by_profile(profile_id INTEGER)
RETURNS SETOF CourseView AS
$$
DECLARE
    profile_courses CourseView;
BEGIN
    FOR profile_courses IN
        SELECT * FROM CourseView WHERE accountId = profile_id
    LOOP
        RETURN NEXT profile_courses;
    END LOOP;
    RETURN;
END;
$$
LANGUAGE PLPGSQL;

select * from get_courses_by_profile(1);

CREATE OR REPLACE PROCEDURE DeleteCourse(courseId INT)
AS $$
BEGIN
    DELETE FROM Courses WHERE id = courseId;
END;
$$ LANGUAGE plpgsql;

Call DeleteCourse(7);
