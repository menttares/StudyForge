-- Создание типа ENUM для статусов заявок
CREATE TYPE STATUS_ENUM AS ENUM('принято', 'отклонено', 'ожидание');

-- Таблица Accounts
CREATE TABLE ACCOUNTS (
	ID SERIAL PRIMARY KEY, -- ID профиля (рукописный ключ)
	EMAIL VARCHAR(100) UNIQUE NOT NULL CHECK (EMAIL LIKE '%@%'), -- Почта (уникальная, не null, обязателен символ'@' в поле)
	PASSWORD VARCHAR(20) NOT NULL CHECK (PASSWORD ~ '^[a-zA-Z\\d@+#\\!]{5,20}$'), -- Пароль (5-20 символов, без пробелов, только цифры, буквы, спецсимволы)
	IS_ORGANIZATION BOOL DEFAULT False, -- Организация, true - является юридическим лицом, иначе физическое - false
	PHONE VARCHAR(60) UNIQUE NOT NULL CHECK (
		PHONE ~ '^\\+375(29|33|44|25|17)\\d{3}\\d{2}\\d{2}$'
	), -- Телефон, но только белорусский
	NAME VARCHAR(100) NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) <= 100
	), -- Имя человека или организации (не null, минимум 3 символа и максимум 60)
	ABOUT_ME VARCHAR(1000), -- О себе (необязательное поле)
	LICENSE_NUMBER VARCHAR(100) UNIQUE NOT NULL CHECK (
		LICENSE_NUMBER ~ '^(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20)\\d{2}\\d{6}\\d{2}$'
	), -- Номер лицензии РБ (Обязательное поле)
	CONFIRMATION BOOL DEFAULT FALSE, -- Поле подтверждения профиля администратором (необязательное поле, т.к. это поле будет проверено в будущем администратором)
	CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Дата создания профиля (автоматически заполняется)
);

-- Таблица Administrators
CREATE TABLE ADMINISTRATORS (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR(100) CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) < 60
	),
	EMAIL VARCHAR(100) UNIQUE NOT NULL CHECK (EMAIL LIKE '%@%'),
	PASSWORD VARCHAR(20) NOT NULL CHECK (PASSWORD ~ '^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*]{6,20}$')
);

-- Вставка данных в таблицу Administrators
INSERT INTO
	ADMINISTRATORS (NAME, EMAIL, PASSWORD)
VALUES
	('Менеджер', 'menttare.h@gmail.com', 'Admin123!');

-- Таблица Categories
CREATE TABLE CATEGORIES (
	ID SERIAL PRIMARY KEY, -- ID
	NAME VARCHAR(100) UNIQUE NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) < 60
	)
);

-- Вставка данных в таблицу Categories
INSERT INTO
	CATEGORIES (NAME)
VALUES
	('IT-сфера'),
	('Бизнес'),
	('Языки'),
	('Дизайн'),
	('Маркетинг'),
	('Музыка'),
	('Здоровье и фитнес'),
	('Стиль жизни'),
	('Учебные и академические дисциплины');

-- Таблица Sections
CREATE TABLE SECTIONS (
	ID SERIAL PRIMARY KEY, -- ID
	ID_CATEGORY INTEGER REFERENCES CATEGORIES (ID) ON DELETE SET NULL, -- FK ключ к разделу, к которому относится раздел
	NAME VARCHAR(100) UNIQUE NOT NULL -- Название Раздела
);

-- Вставка данных в таблицу Sections
INSERT INTO
	SECTIONS (ID_CATEGORY, NAME)
VALUES
	(1, 'Программирование'),
	(1, 'Сетевые технологии'),
	(1, 'Кибербезопасность'),
	(1, 'Базы данных'),
	(1, 'Машинное обучение'),
	(2, 'Управление проектами'),
	(2, 'Финансовый анализ'),
	(2, 'Предпринимательство'),
	(2, 'Маркетинг'),
	(2, 'Стратегическое планирование'),
	(3, 'Английский язык'),
	(3, 'Испанский язык'),
	(3, 'Французский язык'),
	(3, 'Немецкий язык'),
	(3, 'Китайский язык'),
	(4, 'Графический дизайн'),
	(4, 'Веб-дизайн'),
	(4, 'Интерьерный дизайн'),
	(4, 'UX/UI дизайн'),
	(4, '3D-моделирование'),
	(5, 'Социальные медиа'),
	(5, 'SEO'),
	(5, 'Контент-маркетинг'),
	(5, 'Маркетинговые исследования'),
	(5, 'Реклама'),
	(6, 'Игра на гитаре'),
	(6, 'Игра на фортепиано'),
	(6, 'Теория музыки'),
	(6, 'Звукорежиссура'),
	(6, 'Пение'),
	(7, 'Йога'),
	(7, 'Фитнес-тренировки'),
	(7, 'Диетология'),
	(7, 'Медитация'),
	(7, 'Здоровый образ жизни'),
	(8, 'Путешествия'),
	(8, 'Кулинария'),
	(8, 'Фотография'),
	(8, 'Личное развитие'),
	(8, 'Мода'),
	(9, 'Математика'),
	(9, 'Физика'),
	(9, 'Химия'),
	(9, 'Биология'),
	(9, 'История'),
	(9, 'Литература'),
	(9, 'Инженерное дело');

-- Таблица Courses
CREATE TABLE COURSES (
	ID SERIAL PRIMARY KEY, -- ID курса
	ID_SECTION INTEGER REFERENCES SECTIONS (ID), -- Раздел, к которому относится курс
	ID_ACCOUNT INTEGER REFERENCES ACCOUNTS (ID) ON DELETE CASCADE, -- Создатель курса
	NAME VARCHAR(100) NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) <= 100
	), -- Название курса
	PRICE NUMERIC(10, 2) CHECK (
		PRICE >= 0
		AND PRICE < 10000000
	) DEFAULT 0, -- Цена курса
	DESCRIPTION VARCHAR(1000), -- Описание курса
	CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Дата создания (автоматически заполняется)
	COURSE_CLOSED BOOL DEFAULT FALSE, -- Закрыт ли курс организатором?
	TARGET_AUDIENCE VARCHAR(500), -- Для кого этот курс
	PREREQUISITES VARCHAR(500), -- Требования набора
	LEARNING_OUTCOMES VARCHAR(1000), -- На курсе вы научитесь
	DURATION_HOURS INTEGER CHECK (DURATION_HOURS >= 0) -- Длительность в часах
);

-- Таблица FormsTraining
CREATE TABLE FORMSTRAINING (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR(100) UNIQUE NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) < 60
	)
);

-- Вставка данных в таблицу FormsTraining
INSERT INTO
	FORMSTRAINING (NAME)
VALUES
	('Очная'),
	('Заочная'),
	('Очно-заочная');

-- Таблица Cities
CREATE TABLE CITIES (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR(100)  UNIQUE NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) < 60
	)
);

-- Вставка данных в таблицу Cities
INSERT INTO
	CITIES (NAME)
VALUES
	('Минск'),
	('Гомель'),
	('Могилев'),
	('Витебск'),
	('Гродно'),
	('Брест'),
	('Мозырь'),
	('Бобруйск'),
	('Полоцк');

-- Таблица studygroups
CREATE TABLE STUDYGROUPS (
	ID SERIAL PRIMARY KEY,
	ID_COURSE INTEGER REFERENCES COURSES (ID) ON DELETE CASCADE, -- Раздел, к которому относится группа
	ENROLLMENT INTEGER NOT NULL CHECK (
		ENROLLMENT > 0
		AND ENROLLMENT < 300
	), -- Количество мест
	DATE_START DATE DEFAULT CURRENT_DATE, -- Дата начала обучения
	PRICE NUMERIC(10, 2) CHECK (
		PRICE >= 0
		AND PRICE < 10000000
	) DEFAULT 0, -- Цена обучения,
	DURATION INTEGER CHECK (
		PRICE >= 1
		AND PRICE < 100000
	) DEFAULT 1,
	ID_FORMSTRAINING INTEGER REFERENCES FORMSTRAINING (ID) ON DELETE SET NULL, -- Форма обучения
	ID_CITY INTEGER REFERENCES CITIES (ID) ON DELETE SET NULL, -- Город
	CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Дата создания группы
);

-- Таблица StatusApplications
CREATE TABLE STATUSAPPLICATIONS (
	ID SERIAL PRIMARY KEY,
	NAME STATUS_ENUM UNIQUE NOT NULL
);

-- Вставка значений в таблицу StatusApplications
INSERT INTO
	STATUSAPPLICATIONS (NAME)
VALUES
	('принято'),
	('отклонено'),
	('ожидание');

-- Таблица applications
CREATE TABLE APPLICATIONS (
	ID SERIAL PRIMARY KEY,
	ID_STUDYGROUP INTEGER REFERENCES STUDYGROUPS (ID) ON DELETE CASCADE, -- Группа обучения
	FIRSTNAME VARCHAR(60) NOT NULL CHECK (
		LENGTH(FIRSTNAME) >= 3
		AND LENGTH(FIRSTNAME) < 60
	), -- Имя
	LASTNAME VARCHAR(60) NOT NULL CHECK (
		LENGTH(LASTNAME) >= 3
		AND LENGTH(LASTNAME) < 60
	), -- Фамилия
	SURNAME VARCHAR(60) NULL CHECK (LENGTH(SURNAME) < 60), -- Отчество
	PHONE VARCHAR(60) NOT NULL CHECK (
		PHONE ~ '^\\+375(29|33|44|25|17)\\d{3}\\d{2}\\d{2}$'
	), -- Телефон
	BIRTHDAY DATE NOT NULL CHECK (
		EXTRACT(
			YEAR
			FROM
				CURRENT_DATE
		) - EXTRACT(
			YEAR
			FROM
				BIRTHDAY
		) >= 18
		AND BIRTHDAY < CURRENT_DATE
	), -- Дата рождения
	EMAIL VARCHAR(100) NOT NULL CHECK (EMAIL LIKE '%@%'), -- Электронная почта
	ID_STATUSAPPLICATIONS INTEGER REFERENCES STATUSAPPLICATIONS (ID), -- Статус заявки
	CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Дата создания
);

-- Таблица ProgramsCourse
CREATE TABLE PROGRAMSCOURSE (
	ID SERIAL PRIMARY KEY, -- ID 
	NAME VARCHAR(100) NOT NULL CHECK (LENGTH(NAME) >= 3 and LENGTH(NAME) <= 100), -- Название курса
	DESCRIPTION VARCHAR(1000), -- Описание курса
	ID_COURSE INTEGER REFERENCES COURSES (ID) ON DELETE CASCADE -- ID курса
);

-- Таблица Days
CREATE TABLE DAYS (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR(30) UNIQUE NOT NULL CHECK (
		NAME IN ('ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС')
	) -- Дни недели
);

-- Вставка значений в таблицу Days
INSERT INTO
	DAYS (NAME)
VALUES
	('ПН'),
	('ВТ'),
	('СР'),
	('ЧТ'),
	('ПТ'),
	('СБ'),
	('ВС');

-- Таблица timeslot_StudyGroups
CREATE TABLE TIMESLOT_STUDYGROUPS (
	ID SERIAL PRIMARY KEY,
	ID_DAY INTEGER REFERENCES DAYS (ID) ON DELETE CASCADE, -- День недели
	ID_STUDYGROUP INTEGER REFERENCES STUDYGROUPS (ID) ON DELETE CASCADE -- Группа обучения
);



-- функции

CREATE OR REPLACE FUNCTION GetAllDays()
RETURNS SETOF Days
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Days;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_schedule_days(group_id INTEGER, day_ids INTEGER[])
RETURNS BOOLEAN AS
$$
DECLARE
    i INTEGER;
BEGIN
    -- Проверяем существование учебной группы
    IF NOT EXISTS (SELECT 1 FROM studygroups WHERE id = group_id) THEN
        RETURN FALSE;
    END IF;

    -- Если массив day_ids пуст, то удаляем все записи для данной учебной группы
    IF array_length(day_ids, 1) IS NULL THEN
        DELETE FROM timeslot_StudyGroups WHERE id_studyGroup = group_id;
        RETURN TRUE; -- Возвращаем true при успешном удалении
    END IF;

    -- Удаляем все записи для данной учебной группы
    DELETE FROM timeslot_StudyGroups WHERE id_studyGroup = group_id;

    -- Записываем заново все дни из массива id
    FOR i IN 1..array_length(day_ids, 1) LOOP
        INSERT INTO timeslot_StudyGroups (id_studyGroup, id_day) VALUES (group_id, day_ids[i]);
    END LOOP;

    RETURN TRUE; -- Возвращаем true при успешном обновлении
EXCEPTION
    WHEN others THEN
        RETURN FALSE; -- Возвращаем false при ошибке
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_schedule_days(group_id INTEGER)
RETURNS JSON AS
$$
DECLARE
    schedule_days JSON := '[]'::JSON;
BEGIN
    -- Проверяем наличие записей для указанной учебной группы
    IF EXISTS (SELECT 1 FROM timeslot_StudyGroups WHERE id_studyGroup = group_id) THEN
        -- Выбираем ID и названия дней из расписания
        SELECT json_agg(json_build_object('id', s.id_day, 'name', d.name)) INTO schedule_days
        FROM timeslot_StudyGroups s
        JOIN Days d ON s.id_day = d.id
        WHERE s.id_studyGroup = group_id;
    END IF;

    RETURN schedule_days;
EXCEPTION
    WHEN others THEN
        RETURN '[]'::JSON;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION count_accepted_applications(p_group_id INTEGER)
RETURNS INTEGER AS
$$
DECLARE
    accepted_count INTEGER;
BEGIN
    -- Подсчет количества принятых заявок
    SELECT COUNT(*)
    INTO accepted_count
    FROM applications
    WHERE id_StudyGroup = p_group_id
    AND id_StatusApplications = (SELECT id FROM StatusApplications WHERE name = 'принято');

    RETURN accepted_count;
EXCEPTION
    WHEN others THEN
        RETURN -1;
END;
$$
LANGUAGE PLPGSQL;


-- представления
CREATE VIEW AccountDetails AS
SELECT 
    a.id AS account_id,
    a.email,
    a.password,
    a.is_organization,
    a.phone,
    a.name,
    a.about_me,
    a.license_number,
    a.confirmation,
    a.created_at,
    CASE 
        WHEN a.is_organization THEN 'Организация' 
        ELSE 'Физическое лицо' 
    END AS account_type,
    (
        SELECT COUNT(*)
        FROM Courses c
        WHERE c.id_account = a.id
    ) AS course_count
FROM 
    Accounts a;


CREATE VIEW ApplicationsPerCourse AS
SELECT
    c.id AS course_id,
    c.name AS course_name,
    COUNT(a.id) AS application_count,
	c.id_Account AS creator_id
FROM
    Courses c
LEFT JOIN
    StudyGroups sg ON c.id = sg.id_Course
LEFT JOIN
    Applications a ON sg.id = a.id_StudyGroup
GROUP BY
    c.id,
    c.name;

CREATE VIEW ApplicationDetailsView AS
SELECT 
    a.id AS application_id,
    sg.id AS group_id,
    c.id AS course_id,
    c.name AS course_name,
    ft.id AS training_form_id,
    ft.name AS training_form_name,
    city.id AS city_id,
    city.name AS city_name,
    sa.id AS application_status_id,
    sa.name AS application_status_name,
    a.email AS applicant_email,
    acc.id AS creator_profile_id,
    acc.email AS creator_email,
    acc.phone AS creator_phone
FROM 
    applications a
JOIN 
    StudyGroups sg ON a.id_StudyGroup = sg.id
JOIN 
    Courses c ON sg.id_course = c.id
JOIN 
    FormsTraining ft ON sg.id_FormsTraining = ft.id
JOIN 
    Cities city ON sg.id_city = city.id
JOIN 
    StatusApplications sa ON a.id_StatusApplications = sa.id
JOIN 
    Accounts acc ON c.id_Account = acc.id;

CREATE VIEW v_applications_details AS
SELECT
    a.id AS application_id,
    a.firstName,
    a.lastName,
    a.surname,
    a.phone,
    a.birthday,
    a.email,
    a.id_StatusApplications,
    a.created_at,
    sg.id AS studygroup_id,
    sg.enrollment,
    sg.date_start,
    sg.price,
    sg.duration,
    ft.name AS form_training_name,
    c.name AS city_name,
	co.id AS course_id,
	co.name
FROM
    applications a
JOIN
    studygroups sg ON a.id_StudyGroup = sg.id
LEFT JOIN
    FormsTraining ft ON sg.id_FormsTraining = ft.id
LEFT JOIN
    Cities c ON sg.id_city = c.id
JOIN
    courses co ON sg.id_course = co.id;


CREATE OR REPLACE VIEW CourseAndGroupView AS
SELECT
    c.id AS course_id,
    c.name AS course_name,
    c.description AS course_description,
    sec.id AS section_id,
    sec.name AS section_name,
    cr.name AS creator_name,
    cr.email AS creator_email,
    cr.phone AS creator_phone,
    cr.is_organization AS creator_is_organization,
    sg.id AS group_id,
    sg.enrollment AS group_enrollment,
    sg.date_start AS group_date_start,
    sg.price AS group_price,
    sg.duration AS group_duration,
    count_accepted_applications(sg.id) AS accepted_applications_count,
    get_schedule_days(sg.id) AS schedule_days,
    c.course_closed AS course_closed,
    ft.name AS form_training_name,
    city.name AS city_name
FROM
    courses c
JOIN
    studygroups sg ON c.id = sg.id_course
JOIN
    accounts cr ON c.id_Account = cr.id
JOIN 
    Sections sec ON sec.id = c.id_Section
JOIN
    FormsTraining ft ON sg.id_FormsTraining = ft.id
JOIN
    Cities city ON sg.id_city = city.id;

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


CREATE OR REPLACE VIEW application_details_view AS
SELECT 
    a.id AS ApplicationId,
    a.id_StudyGroup AS GroupId,
    sg.id_Course AS CourseId,
    c.name AS CourseName,
    sg.id_FormsTraining AS TrainingFormId,
    tf.name AS TrainingFormName,
    sg.id_City AS CityId,
    ct.name AS CityName,
    a.id_StatusApplications AS ApplicationStatusId,
    sa.name AS ApplicationStatusName,
    a.email AS ApplicantEmail,
    u.id AS CreatorProfileId,
    u.email AS CreatorEmail,
    u.phone AS CreatorPhone
FROM 
    applications a
JOIN 
    StudyGroups sg ON a.id_StudyGroup = sg.id
JOIN 
    Courses c ON sg.id_Course = c.id
JOIN 
    FormsTraining tf ON sg.id_FormsTraining = tf.id
JOIN 
    Cities ct ON sg.id_City = ct.id
JOIN 
    StatusApplications sa ON a.id_StatusApplications = sa.id
JOIN 
    Accounts u ON c.id_Account = u.id;

select * from application_details_view;

CREATE OR REPLACE VIEW StudyGroupsView AS
SELECT
    sg.id,
    sg.enrollment,
    sg.date_start,
    sg.price,
    sg.id_FormsTraining,
    sg.id_city,
    sg.duration,
    sg.id_course,
    count_accepted_applications(sg.id) AS accepted_applications_count,
    get_schedule_days(sg.id) AS schedule_days,
	ft.name AS form_training_name,
	city.name AS city_name
FROM
    studygroups sg
JOIN
    FormsTraining ft ON sg.id_FormsTraining = ft.id
JOIN
    Cities city ON sg.id_city = city.id
JOIN
    courses c ON sg.id_course = c.id;



CREATE VIEW CategorySections AS
SELECT
    c.id AS categoryId,
    c.name AS category,
    s.id AS sectionId,
    s.name AS subsection
FROM
    CATEGORIES c
JOIN
    Sections s ON c.id = s.id_category;

select * from CategorySections;


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
    CATEGORIES c
JOIN
    Sections s ON c.id = s.id_Category
JOIN
    Courses cr ON s.id = cr.id_Section
JOIN
    Accounts ac ON ac.id = cr.id_Account;


CREATE VIEW UserProfileInfo AS
SELECT
    a.id AS account_id,
    a.email,
    a.phone,
    a.name,
    a.about_me,
    a.license_number,
    a.confirmation,
    a.created_at AS account_created_at
FROM
    Accounts a;



CREATE OR REPLACE FUNCTION get_user_profile_info(p_profile_id INTEGER)
RETURNS UserProfileInfo AS
$$
DECLARE
    user_profile UserProfileInfo;
BEGIN
    SELECT * INTO user_profile
    FROM UserProfileInfo
    WHERE account_id = p_profile_id;

    RETURN user_profile;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id INTEGER,
    p_name VARCHAR,
    p_about_me VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR
) 
RETURNS BOOLEAN AS
$$
BEGIN
    -- Обновляем информацию о пользователе
    UPDATE Accounts
    SET 
        name = p_name,
        about_me = p_about_me,
        email = p_email,
        phone = p_phone
    WHERE
        id = p_user_id;

    -- Проверяем, было ли выполнено успешное обновление
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN others THEN
        -- Обработка исключения: возвращаем FALSE в случае ошибки
        RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION login_admin(p_login VARCHAR, p_password VARCHAR, OUT result_id INTEGER)
AS $$
DECLARE
    admin_id INTEGER;
    stored_password VARCHAR;
BEGIN
    -- Проверяем, существует ли администратор с указанным логином
    SELECT id, password INTO admin_id, stored_password FROM Administrators WHERE email = p_login LIMIT 1;

    -- Если администратор не найден, возвращаем -1
    IF admin_id IS NULL THEN
        result_id := -1;
        RETURN;
    END IF;

    -- Проверяем совпадение паролей
    IF stored_password <> p_password THEN
        result_id := -2;
        RETURN;
    ELSE
        -- Если все проверки пройдены успешно, возвращаем id
        result_id := admin_id;
        RETURN;
    END IF;

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        result_id := 0;
        RETURN;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION register_profile(
    p_name VARCHAR,
    p_license_number VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_is_organization BOOL,
    p_phone VARCHAR
) 
RETURNS INTEGER
AS $$
DECLARE
    result_id INTEGER;
BEGIN
    -- Проверяем, существует ли уже пользователь с таким email
    SELECT id INTO result_id FROM Accounts WHERE email = p_email LIMIT 1;
    IF FOUND THEN
        RETURN -1;
    END IF;
    
    -- Проверяем, существует ли уже пользователь с такой лицензией
    SELECT id INTO result_id FROM Accounts WHERE license_number = p_license_number LIMIT 1;
    IF FOUND THEN
        RETURN -2;
    END IF;

    -- Проверяем, существует ли уже пользователь с таким телефоном
    SELECT id INTO result_id FROM Accounts WHERE phone = p_phone LIMIT 1;
    IF FOUND THEN
        RETURN -3;
    END IF;

    -- Добавляем новый профиль
    INSERT INTO Accounts (name, license_number, email, password, is_organization, phone)
    VALUES (p_name, p_license_number, p_email, p_password, p_is_organization, p_phone)
    RETURNING id INTO result_id;

    -- Возвращаем id нового пользователя
    RETURN result_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Возвращаем код ошибки
        RETURN 0;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION login_user(p_email VARCHAR, p_password VARCHAR) 
RETURNS INTEGER
AS $$
DECLARE
    user_id INTEGER;
    stored_password VARCHAR;
BEGIN
    -- Проверяем, существует ли пользователь с указанным email
    SELECT id, password INTO user_id, stored_password FROM Accounts WHERE email = p_email LIMIT 1;

    -- Если email не найден, возвращаем -1
    IF user_id IS NULL THEN
        RETURN -1;
    END IF;

    -- Проверяем совпадение паролей
    IF stored_password <> p_password THEN
        RETURN -2;
    ELSE
        -- Если все проверки пройдены успешно, возвращаем id пользователя
        RETURN user_id;
    END IF;

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        RETURN 0;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION GetApplicationDetails(applicationId INT)
RETURNS setof ApplicationDetailsView
AS $$
BEGIN
    RETURN QUERY 
    SELECT *
    FROM 
        ApplicationDetailsView ad
    WHERE 
        ad.application_id = applicationId;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_account_confirmation(
    p_user_id INTEGER
) 
RETURNS BOOLEAN AS $$
DECLARE
    is_confirmed BOOLEAN;
BEGIN
    -- Инициализируем переменную значениями по умолчанию
    is_confirmed := false;

    -- Проверяем, подтвержден ли аккаунт с указанным ID
    SELECT confirmation INTO is_confirmed FROM Accounts WHERE id = p_user_id;

    -- Возвращаем результат проверки
    RETURN is_confirmed;
EXCEPTION
    -- Обрабатываем исключения
    WHEN OTHERS THEN
        -- В случае ошибки возвращаем false
        RETURN false;
END;
$$ LANGUAGE PLPGSQL;


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


CREATE OR REPLACE PROCEDURE DeleteCourse(courseId INT)
AS $$
BEGIN
    DELETE FROM Courses WHERE id = courseId;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION create_study_group(
    p_enrollment INTEGER,
    p_date_start DATE,
    p_date_end DATE,
    p_price NUMERIC(10, 2),
    p_id_FormsTraining INTEGER,
    p_id_city INTEGER,
    p_duration INTEGER,
    p_id_course INTEGER
) 
RETURNS INTEGER AS
$$
DECLARE
    new_group_id INTEGER;
BEGIN
    BEGIN
        INSERT INTO studygroups (enrollment, date_start, date_end, price, id_FormsTraining, id_city, duration, id_course)
        VALUES (p_enrollment, p_date_start, p_date_end, p_price, p_id_FormsTraining, p_id_city, p_duration, p_id_course)
        RETURNING id INTO new_group_id;
    EXCEPTION
        WHEN others THEN
            RETURN 0;
    END;

    IF new_group_id IS NOT NULL THEN
        RETURN new_group_id;
    ELSE
        RETURN 0;
    END IF;
END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION update_study_group(
    p_id INTEGER,
    p_enrollment INTEGER,
    p_date_start DATE,
    p_date_end DATE,
    p_price NUMERIC(10, 2),
    p_id_forms_training INTEGER,
    p_id_city INTEGER,
    p_duration INTEGER
) 
RETURNS BOOLEAN AS
$$
BEGIN
    UPDATE studygroups
    SET 
        enrollment = p_enrollment,
        date_start = p_date_start,
        date_end = p_date_end,
        price = p_price,
        id_FormsTraining = p_id_forms_training,
        id_city = p_id_city,
        duration = p_duration
    WHERE
        id = p_id;

    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION get_course_instances(p_course_id INTEGER)
RETURNS SETOF CourseAndGroupView AS $$
BEGIN
  RETURN QUERY
  SELECT
	*
  FROM
    CourseAndGroupView c
  WHERE
    c.course_id = p_course_id;
END;
$$ LANGUAGE plpgsql;

select * from get_course_instances(17);


CREATE OR REPLACE FUNCTION filter_courses_and_groups(
    p_section_id INTEGER,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_min_price NUMERIC(10, 2) DEFAULT NULL,
    p_max_price NUMERIC(10, 2) DEFAULT NULL,
    p_duration_hours INTEGER DEFAULT NULL,
    p_organization_only BOOLEAN DEFAULT FALSE,
    p_free_only BOOLEAN DEFAULT FALSE,
	p_search_query VARCHAR DEFAULT NULL
) 
RETURNS SETOF CourseAndGroupView AS
$$
DECLARE
    filter_conditions TEXT := ' WHERE course_closed = FALSE';
BEGIN
    -- Формируем условия для фильтрации

    IF p_section_id IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND section_id = ' || p_section_id;
    END IF;

    IF p_start_date IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_date_start >= ' || quote_literal(p_start_date);
    END IF;

    IF p_end_date IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_date_end <= ' || quote_literal(p_end_date);
    END IF;

    IF p_min_price IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_price >= ' || p_min_price;
    END IF;

    IF p_max_price IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_price <= ' || p_max_price;
    END IF;

    IF p_duration_hours IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_duration = ' || p_duration_hours;
    END IF;

    IF p_organization_only THEN
        filter_conditions := filter_conditions || ' AND creator_is_organization = TRUE';
    END IF;

    IF p_free_only THEN
        filter_conditions := filter_conditions || ' AND accepted_applications_count < group_enrollment';
    END IF;

    IF p_search_query IS NOT NULL THEN
        -- Добавляем условие для поиска по частичному совпадению в названии курса и имени организатора
        filter_conditions := filter_conditions || ' AND (LOWER(course_name) LIKE LOWER(' || quote_literal('%' || p_search_query || '%') || ')' ||
                                               ' OR LOWER(creator_name) LIKE LOWER(' || quote_literal('%' || p_search_query || '%') || '))';
    END IF;

    -- Условие для исключения забаненных курсов
    filter_conditions := filter_conditions || ' AND course_id NOT IN (SELECT id_Course FROM BannedCourses)';

    RETURN QUERY EXECUTE '
        SELECT *
        FROM CourseAndGroupView
        ' || filter_conditions;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_all_forms_training()
RETURNS TABLE (
    form_id INT,
    form_name VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY SELECT id AS form_id, name AS form_name FROM FormsTraining;
END;
$$ LANGUAGE PLPGSQL;

-- Функция для вывода всех данных из таблицы Cities
CREATE OR REPLACE FUNCTION get_all_cities()
RETURNS TABLE (
    city_id INT,
    city_name VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY SELECT id AS city_id, name AS city_name FROM Cities;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_study_groups_by_course_id(p_course_id INTEGER)
RETURNS SETOF StudyGroupsView AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id_course = p_course_id;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION get_study_groups_by_creater_id(p_creater_id INTEGER)
RETURNS SETOF StudyGroupsView AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id = p_creater_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_study_group_by_id(p_group_id INTEGER)
RETURNS SETOF StudyGroupsView AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id = p_group_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION delete_study_group_by_id(p_group_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
    DELETE FROM studygroups WHERE id = p_group_id;

    IF FOUND THEN
        RETURN 1;
    ELSE
        RETURN 0; -- Группа с указанным id не найдена
    END IF;

EXCEPTION
    WHEN others THEN
        RETURN 0; -- Произошла ошибка при удалении
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION GetCourseApplicationsStatisticsByCreatorId(p_creator_id INTEGER)
RETURNS SETOF ApplicationsPerCourse AS
$$
BEGIN
    RETURN QUERY
    SELECT *
    FROM ApplicationsPerCourse
    WHERE creator_id = p_creator_id;
END;
$$
LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION create_application(
	p_id_StudyGroup INTEGER,
    p_firstName VARCHAR(60),
    p_lastName VARCHAR(60),
    p_surname VARCHAR(60),
    p_phone VARCHAR(15),
    p_birthday DATE,
	p_email VARCHAR(255)
) 
RETURNS INTEGER AS
$$
DECLARE
    new_id INTEGER;
    status_id INTEGER;
BEGIN
    -- Получаем ID статуса "Ожидание"
    SELECT id INTO status_id FROM StatusApplications WHERE name = 'ожидание';

    -- Вставляем новую запись в таблицу applications
    INSERT INTO applications (id_StudyGroup, firstName, lastName, surname, phone, birthday, id_StatusApplications, email) 
    VALUES (p_id_StudyGroup, p_firstName, p_lastName, p_surname, p_phone, p_birthday, status_id, p_email)
    RETURNING id INTO new_id;

    RETURN new_id;
EXCEPTION
    WHEN others THEN
        RETURN 0;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION update_application_status(
    p_application_id INTEGER,
    p_new_status_id INTEGER
) 
RETURNS BOOLEAN AS
$$
BEGIN
    -- Обновляем статус заявки
    UPDATE applications
    SET 
        id_StatusApplications = p_new_status_id
    WHERE
        id = p_application_id;

    -- Проверяем, было ли выполнено успешное обновление
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
	
	EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION get_applications(
    p_id_course INTEGER,
    p_id_status INTEGER DEFAULT NULL
)
RETURNS SETOF v_applications_details AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.*
    FROM 
        v_applications_details v
    WHERE 
        v.course_id = p_id_course
        AND (v.id_StatusApplications = p_id_status OR p_id_status IS NULL);
END;
$$ LANGUAGE plpgsql;


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



