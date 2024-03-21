

--  Функция аунтификации пользоватлея
CREATE OR REPLACE FUNCTION login_user(p_email VARCHAR, p_password VARCHAR) 
RETURNS INTEGER AS
$$
DECLARE
    user_id INTEGER;
    stored_password VARCHAR;
BEGIN
    -- Проверяем, существует ли пользователь с указанным email
    SELECT id, password INTO user_id, stored_password FROM profile WHERE email = p_email LIMIT 1;

    -- Если email не найден, возвращаем -1
    IF user_id IS NULL THEN
        RETURN -1;
    END IF;

    -- Проверяем совпадение паролей
    IF stored_password <> p_password THEN
        RETURN -2;
    ELSE
        -- Если все проверки пройдены успешно, возвращаем id
        RETURN user_id;
    END IF;

--EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    --WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        --RETURN 0;
END;
$$
LANGUAGE PLPGSQL;

select  login_user('user1@example.com','password123');


-- функция регистрация
CREATE OR REPLACE FUNCTION register_profile(
    p_name VARCHAR,
    p_license_number VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_is_organization BOOL,
    p_phone VARCHAR
) 
RETURNS INTEGER AS
$$
DECLARE
    inserted_id INTEGER;
BEGIN
    -- Проверяем, существует ли уже пользователь с таким email
    IF EXISTS (SELECT 1 FROM profile WHERE email = p_email) THEN
        RETURN -1; -- Пользователь с таким email уже существует
    END IF;
	
	-- проверяем, существует ли такой пользователь с такой лицензией
	IF EXISTS (SELECT 1 FROM profile WHERE license_number = p_license_number) THEN
        RETURN -3; -- Пользователь с таким license_number уже существует
    END IF;

    -- добавляем новый профиль
    INSERT INTO profile (name, license_number, email, password, is_organization, phone)
    VALUES (p_name, p_license_number, p_email, p_password, p_is_organization, p_phone)
    RETURNING id INTO inserted_id;

    RETURN inserted_id; -- Возвращаем ID при успехе

EXCEPTION
    WHEN OTHERS THEN
        --Возвращаем 0 в случае ошибки
        RETURN 0;
END;
$$
LANGUAGE PLPGSQL;


SELECT register_profile(
    'Антон Антонович', -- Имя пользователя
    '012305001198', -- Номер лицензии
    'anton.anton@gmail.com', -- Email
    'password123', -- Пароль
    FALSE, -- Поле организации (FALSE - физическое лицо, TRUE - юридическое лицо)
    '+375297634577' -- Номер телефона
);



SELECT register_profile(
    'Антон Антонович', -- Имя пользователя
    '012305001198', -- Номер лицензии
    'anton.anton@gmail.com', -- Email
    'password123', -- Пароль
    FALSE, -- Поле организации (FALSE - физическое лицо, TRUE - юридическое лицо)
    '+375297634577' -- Номер телефона
);

CREATE OR REPLACE FUNCTION get_accepted_applications_count(group_id INT) RETURNS INT AS $$
DECLARE
    accepted_count INT;
BEGIN
    SELECT COUNT(*)
    INTO accepted_count
    FROM applications
    WHERE id_study_group = group_id AND id_status_applications = (SELECT id FROM status_applications WHERE Name = 'Принято');

    RETURN accepted_count;
END;
$$ LANGUAGE plpgsql;

select * from get_accepted_applications_count(1);

CREATE OR REPLACE FUNCTION get_study_days(group_id INT) RETURNS TEXT AS $$
DECLARE
    study_days_text TEXT := '';
BEGIN
    SELECT STRING_AGG(d.Name, ', ')
    INTO study_days_text
    FROM timeslot_study_group tsg
    JOIN days d ON tsg.id_day = d.id
    WHERE tsg.id_study_group = group_id;

    RETURN COALESCE(study_days_text, 'дни неоперделены');
END;
$$ LANGUAGE plpgsql;


select * from get_study_days(1);

CREATE VIEW study_group_view AS
SELECT sg.id AS group_id,
       sg.enrollment,
       sg.date_start,
       sg.date_end,
       sg.price,
	   fs.id AS id_form_of_study,
       fs.Name AS form_of_study,
	   c.id AS id_city,
       c.Name AS city,
       sg.duration,
	   c1.id AS id_course_name,
       c1.name AS course_name,
       c1.description AS course_description,
	   s.id AS if_section,
       s.name AS section_name,
	   p.id AS id_profile,
	   p.name AS name_profile,
	   p.is_organization AS is_organization_profile,
	   get_accepted_applications_count(sg.id) AS accepted_applications_count,
       get_study_days(sg.id) AS study_days
FROM study_group sg
JOIN form_study fs ON sg.id_form_study = fs.id
LEFT JOIN city c ON sg.id_city = c.ID
JOIN courses c1 ON sg.id_course = c1.id
JOIN section s ON c1.id_section = s.id
JOIN profile p ON p.id = c1.id_profile;



select * from study_group_view;




CREATE OR REPLACE FUNCTION search_study_group_view(
    p_category_id INT DEFAULT NULL,
    p_form_of_study_id INT DEFAULT NULL,
    p_city_id INT DEFAULT NULL,
    p_search_string VARCHAR DEFAULT NULL,
    p_start_price NUMERIC DEFAULT NULL,
    p_end_price NUMERIC DEFAULT NULL,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_is_organization BOOLEAN DEFAULT NULL,
    p_has_vacancies BOOLEAN DEFAULT NULL,
	p_course_id INT DEFAULT NULL
) RETURNS TABLE (
    group_id INT,
    enrollment INT,
    date_start DATE,
    date_end DATE,
    price NUMERIC,
	id_form_study integer,
	name_form_study VARCHAR,
	id_course integer,
    course_name VARCHAR,
	course_description VARCHAR,
	id_section integer,
    section_name VARCHAR,
	id_profile integer,
    name_profile VARCHAR,
	id_city integer,
	city_name varchar,
    accepted_applications_count INT,
    study_days TEXT,
	is_organization bool,
	duration integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sg.id AS group_id, -- 0
        sg.enrollment, -- 1
        sg.date_start, -- 2
        sg.date_end, -- 3
        sg.price, -- 4
		fs.id AS id_form_study, -- 5
		fs.name AS name_form_study, -- 6
		c1.id AS id_course, --7
        c1.name AS course_name, -- 8
		c1.description as course_description, -- 9
		s.id AS id_section, --10
        s.name AS section_name, -- 11
		p.id AS id_profile, -- 12
        p.name AS name_profile, -- 13
		c.id AS id_city,
		c.name AS city_name,
        get_accepted_applications_count(sg.id) AS accepted_applications_count, -- 14
        get_study_days(sg.id) AS study_days, -- 15
		p.is_organization AS is_organization,
		sg.duration as duration
    FROM 
        study_group sg
    JOIN 
        courses c1 ON sg.id_course = c1.id
    JOIN 
        section s ON c1.id_section = s.id
    JOIN 
        profile p ON p.id = c1.id_profile
	JOIN
		form_study fs ON fs.id = sg.id_form_study
	JOIN
		city c ON c.id = sg.id_city
    WHERE
        (p_category_id IS NULL OR c1.id_section = p_category_id) AND
        (p_form_of_study_id IS NULL OR sg.id_form_study = p_form_of_study_id) AND
        (p_city_id IS NULL OR sg.id_city = p_city_id) AND
        (p_search_string IS NULL OR (c1.name ILIKE '%' || p_search_string || '%' OR c1.description ILIKE '%' || p_search_string || '%' OR p.name ILIKE '%' || p_search_string || '%')) AND
        (p_start_price IS NULL OR sg.price >= p_start_price) AND
        (p_end_price IS NULL OR sg.price <= p_end_price) AND
        (p_start_date IS NULL OR sg.date_start >= p_start_date) AND
        (p_end_date IS NULL OR sg.date_end <= p_end_date) AND
        (p_is_organization IS NULL OR p.is_organization = p_is_organization) AND
        (p_has_vacancies IS NULL OR sg.enrollment > get_accepted_applications_count(sg.id)) AND
		(p_course_id IS NULL OR sg.id_course = p_course_id);
END;
$$ LANGUAGE plpgsql;

select * from search_study_group_view();

SELECT *
FROM search_study_group_view(
    2, -- p_category_name
    NULL, -- p_search_string
    NULL, -- p_start_price
    NULL, -- p_end_price
    NULL, -- p_start_date
    NULL, -- p_end_date
    NULL, -- p_city_name
    NULL, -- p_form_of_study_name
    NULL, -- p_is_organization
    NULL,  -- p_has_vacancies
	NULL
);



CREATE OR REPLACE FUNCTION get_categories_with_sections()
RETURNS TABLE (category_name VARCHAR(255), section_name VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY
    SELECT c.name AS category_name, s.name AS section_name
    FROM category c
    LEFT JOIN section s ON c.id = s.id_category;
END;
$$ LANGUAGE plpgsql;


select * from get_categories_with_sections();



CREATE OR REPLACE FUNCTION get_course_by_id(p_course_id_param INTEGER) 
RETURNS TABLE (
    course_id INTEGER,
    id_section INTEGER,
    id_profile INTEGER,
    course_name VARCHAR(60),
    course_description VARCHAR(500),
    created_at TIMESTAMP,
    course_closed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.id_section,
        c.id_profile,
        c.name,
        c.description,
        c.created_at,
        c.course_closed
    FROM 
        courses c
    WHERE 
        c.id = p_course_id_param;
END;
$$ LANGUAGE plpgsql;

select * from get_course_by_id(1);


CREATE OR REPLACE FUNCTION GetAllSections()
RETURNS TABLE(id INTEGER, id_category INTEGER, name VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY (
        SELECT *
        FROM section
    );
END;
$$ LANGUAGE plpgsql;



select * from GetAllSections();






CREATE OR REPLACE FUNCTION GetProgramsByCourseId(courseId INTEGER)
RETURNS TABLE (
    program_id INTEGER,
    program_name VARCHAR(255),
    program_description VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY (
        SELECT 
            id,
            name,
            description
        FROM 
            program_course
        WHERE 
            id_course = courseId
    );
END;
$$ LANGUAGE plpgsql;

select * from GetProgramsByCourseId(1);


CREATE OR REPLACE FUNCTION GetTeachersByCourseId(courseId INTEGER)
RETURNS TABLE (
    teacher_id INTEGER,
    teacher_first_name VARCHAR(255),
    teacher_about_me VARCHAR(500),
    teacher_skills VARCHAR(255),
    teacher_specialization VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY (
        SELECT 
            id,
            FirstName,
            AboutMe,
            Skills,
            Specialization
        FROM 
            teacher
        WHERE 
            id_course = courseId
    );
END;
$$ LANGUAGE plpgsql;


select * from GetTeachersByCourseId(1);

select * from GetTeachersByCourseId(1);




CREATE VIEW course_view AS
SELECT 
    c.id AS course_id,
    c.name AS course_name,
    c.description AS course_description,
    c.created_at AS course_created_at,
    c.course_closed AS course_closed,
    s.id AS section_id,
    s.name AS section_name,
    p.id AS profile_id,
    p.name AS profile_name,
    p.is_organization AS profile_is_organization
FROM 
    courses c
JOIN 
    section s ON c.id_section = s.id
JOIN 
    profile p ON c.id_profile = p.id;


select * from get_course_by_id(1);


DROP FUNCTION IF EXISTS get_course_by_id(integer);

CREATE OR REPLACE FUNCTION get_course_by_id(p_course_id INT) RETURNS TABLE (
    course_id INT,
    course_name VARCHAR(60),
    course_description VARCHAR(500),
    course_created_at TIMESTAMP,
    course_closed BOOLEAN,
    section_id INT,
    section_name VARCHAR(255),
    profile_id INT,
    profile_name VARCHAR(255),
    about_me TEXT,
    specialization VARCHAR(255),
    confirmation BOOLEAN,
    profile_is_organization BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id AS course_id,
        c.name AS course_name,
        c.description AS course_description,
        c.created_at AS course_created_at,
        c.course_closed AS course_closed,
        s.id AS section_id,
        s.name AS section_name,
        p.id AS profile_id,
        p.name AS profile_name,
		p.about_me AS about_me,
		p.specialization AS specialization,
		p.confirmation AS confirmation,
        p.is_organization AS profile_is_organization
    FROM 
        courses c
    JOIN 
        section s ON c.id_section = s.id
    JOIN 
        profile p ON c.id_profile = p.id
    WHERE
        c.id = p_course_id;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION create_application(
    p_study_group_id INTEGER,
    p_first_name VARCHAR(255),
    p_phone VARCHAR(255),
    p_birthday timestamp
) RETURNS INTEGER AS $$
DECLARE
    application_id INTEGER;
    status_id INTEGER;
BEGIN
    -- Получаем ID статуса по его имени
    SELECT id INTO status_id FROM status_applications WHERE name = 'В ожидании';

    -- Вставляем новую заявку
    INSERT INTO applications (id_study_group, FirstName, phone, birthday, id_status_applications)
    VALUES (p_study_group_id, p_first_name, p_phone, p_birthday, status_id)
    RETURNING id INTO application_id;

    -- Возвращаем ID созданной заявки
    RETURN application_id;
END;
$$ LANGUAGE plpgsql;


SELECT create_application(
    p_study_group_id := 1, -- ID учебной группы
    p_first_name := 'Иван Иванович Иванов', -- Имя
    p_phone := '+375291234567', -- Телефон
    p_birthday := '2000-01-01' -- Дата рождения
);



CREATE OR REPLACE FUNCTION get_profile_data(profile_id INTEGER) RETURNS profile AS $$
DECLARE
    profile_data profile;
BEGIN
    SELECT *
    INTO profile_data
    FROM profile
    WHERE id = profile_id;

    RETURN profile_data;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_profile_data(1);


CREATE OR REPLACE FUNCTION get_profile_courses(p_profile_id INT) RETURNS TABLE (
    course_id INT,
    course_name VARCHAR(255),
    course_description varchar(500)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS course_id,
        c.name AS course_name,
        c.description AS course_description
    FROM
        courses c
    WHERE
        c.id = p_profile_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_profile_courses(1);





CREATE OR REPLACE FUNCTION get_applications_by_status(p_status_id INT, p_profile_id INT) 
RETURNS TABLE (
    application_id INT,
    id_study_group INT,
    study_group_enrollment INT,
    study_group_date_start DATE,
    study_group_date_end DATE,
    study_group_price NUMERIC(10, 2),
    study_group_id_form_study INT,
    study_group_id_city INT,
    study_group_duration INT,
    study_group_id_course INT,
    FirstName VARCHAR(255),
    phone VARCHAR(255),
    birthday DATE,
    id_status_applications INT
) 
AS $$
BEGIN
    IF p_status_id IS NULL THEN
        RETURN QUERY
        SELECT 
            a.id AS application_id,
            sg.id AS id_study_group,
            sg.enrollment AS study_group_enrollment,
            sg.date_start AS study_group_date_start,
            sg.date_end AS study_group_date_end,
            sg.price AS study_group_price,
            sg.id_form_study AS study_group_id_form_study,
            sg.id_city AS study_group_id_city,
            sg.duration AS study_group_duration,
            sg.id_course AS study_group_id_course,
            a.FirstName,
            a.phone,
            a.birthday,
            a.id_status_applications
        FROM 
            applications a
        JOIN
            study_group sg ON a.id_study_group = sg.id;
    ELSE
        RETURN QUERY
        SELECT 
            a.id AS application_id,
            sg.id AS id_study_group,
            sg.enrollment AS study_group_enrollment,
            sg.date_start AS study_group_date_start,
            sg.date_end AS study_group_date_end,
            sg.price AS study_group_price,
            sg.id_form_study AS study_group_id_form_study,
            sg.id_city AS study_group_id_city,
            sg.duration AS study_group_duration,
            sg.id_course AS study_group_id_course,
            a.FirstName,
            a.phone,
            a.birthday,
            a.id_status_applications
        FROM 
            applications a
        JOIN
            study_group sg ON a.id_study_group = sg.id
		JOIN
			courses c ON c.id = sg.id_course
        WHERE 
            a.id_status_applications = p_status_id and c.id_profile = p_profile_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

select * from get_applications_by_status(1,1);



CREATE OR REPLACE FUNCTION change_application_status(new_status_id INTEGER, application_id INTEGER) RETURNS VOID AS $$
BEGIN
    UPDATE applications SET id_status_applications = new_status_id WHERE id = application_id;
END;
$$ LANGUAGE plpgsql;

SELECT change_application_status(2, 68);
