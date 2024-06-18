-- Создание типа ENUM для статусов заявок
CREATE TYPE STATUS_ENUM AS ENUM('принято', 'отклонено', 'ожидание');

-- Таблица Accounts
CREATE TABLE ACCOUNTS (
	ID SERIAL PRIMARY KEY, -- ID профиля (рукописный ключ)
	EMAIL VARCHAR(100) UNIQUE NOT NULL CHECK (EMAIL LIKE '%@%'), -- Почта (уникальная, не null, обязателен символ'@' в поле)
	PASSWORD VARCHAR(20) NOT NULL CHECK (PASSWORD ~ '^[a-zA-Z\d@+#\\!]{5,20}$'), -- Пароль (5-20 символов, без пробелов, только цифры, буквы, спецсимволы)
	IS_ORGANIZATION BOOL DEFAULT FALSE, -- Организация, true - является юридическим лицом, иначе физическое - false
	PHONE VARCHAR(60) UNIQUE NOT NULL CHECK (
		PHONE ~ '^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$'
	), -- Телефон, но только белорусский
	NAME VARCHAR(100) NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) <= 100
	), -- Имя человека или организации (не null, минимум 3 символа и максимум 60)
	ABOUT_ME VARCHAR(1000), -- О себе (необязательное поле)
	LICENSE_NUMBER VARCHAR(100) UNIQUE NOT NULL CHECK (
		LICENSE_NUMBER ~ '^\d{2}\d{5,}$'
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
	PASSWORD VARCHAR(20) NOT NULL CHECK (
		PASSWORD ~ '^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*]{6,20}$'
	)
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
	('дисциплины');

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
	DURATION_HOURS INTEGER CHECK (DURATION_HOURS >= 0) -- Длительность в часах
);

CREATE TABLE BANNEDCOURSES (
	-- ID записи о забаненном курсе
	ID SERIAL PRIMARY KEY,
	-- ID забаненного курса
	ID_COURSE INTEGER REFERENCES COURSES (ID) ON DELETE CASCADE,
	-- ID администратора, который забанил курс
	ID_ADMINISTRATOR INTEGER REFERENCES ACCOUNTS (ID) ON DELETE SET NULL,
	CAUSE VARCHAR(500) NOT NULL CHECK (
		LENGTH(CAUSE) >= 3
		AND LENGTH(CAUSE) <= 500
	),
	-- Дата и время забана курса
	BANNED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
	NAME VARCHAR(100) UNIQUE NOT NULL CHECK (
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
		PHONE ~ '^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$'
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
	NAME VARCHAR(100) NOT NULL CHECK (
		LENGTH(NAME) >= 3
		AND LENGTH(NAME) <= 100
	), -- Название курса
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
CREATE
OR REPLACE FUNCTION GETALLDAYS () RETURNS SETOF DAYS AS $$
BEGIN
    RETURN QUERY SELECT * FROM Days;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_SCHEDULE_DAYS (GROUP_ID INTEGER, DAY_IDS INTEGER[]) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_SCHEDULE_DAYS (GROUP_ID INTEGER) RETURNS JSON AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION COUNT_ACCEPTED_APPLICATIONS (P_GROUP_ID INTEGER) RETURNS INTEGER AS $$
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
$$ LANGUAGE PLPGSQL;

-- представления
CREATE VIEW ACCOUNTDETAILS AS
SELECT
	A.ID AS ACCOUNT_ID,
	A.EMAIL,
	A.PASSWORD,
	A.IS_ORGANIZATION,
	A.PHONE,
	A.NAME,
	A.ABOUT_ME,
	A.LICENSE_NUMBER,
	A.CONFIRMATION,
	A.CREATED_AT,
	CASE
		WHEN A.IS_ORGANIZATION THEN 'Организация'
		ELSE 'Физическое лицо'
	END AS ACCOUNT_TYPE,
	(
		SELECT
			COUNT(*)
		FROM
			COURSES C
		WHERE
			C.ID_ACCOUNT = A.ID
	) AS COURSE_COUNT
FROM
	ACCOUNTS A;

CREATE VIEW APPLICATIONSPERCOURSE AS
SELECT
	C.ID AS COURSE_ID,
	C.NAME AS COURSE_NAME,
	COUNT(A.ID) AS APPLICATION_COUNT,
	C.ID_ACCOUNT AS CREATOR_ID
FROM
	COURSES C
	LEFT JOIN STUDYGROUPS SG ON C.ID = SG.ID_COURSE
	LEFT JOIN APPLICATIONS A ON SG.ID = A.ID_STUDYGROUP
GROUP BY
	C.ID,
	C.NAME;

CREATE VIEW APPLICATIONDETAILSVIEW AS
SELECT
	A.ID AS APPLICATION_ID,
	SG.ID AS GROUP_ID,
	C.ID AS COURSE_ID,
	C.NAME AS COURSE_NAME,
	FT.ID AS TRAINING_FORM_ID,
	FT.NAME AS TRAINING_FORM_NAME,
	CITY.ID AS CITY_ID,
	CITY.NAME AS CITY_NAME,
	SA.ID AS APPLICATION_STATUS_ID,
	SA.NAME AS APPLICATION_STATUS_NAME,
	A.EMAIL AS APPLICANT_EMAIL,
	ACC.ID AS CREATOR_PROFILE_ID,
	ACC.EMAIL AS CREATOR_EMAIL,
	ACC.PHONE AS CREATOR_PHONE
FROM
	APPLICATIONS A
	JOIN STUDYGROUPS SG ON A.ID_STUDYGROUP = SG.ID
	JOIN COURSES C ON SG.ID_COURSE = C.ID
	JOIN FORMSTRAINING FT ON SG.ID_FORMSTRAINING = FT.ID
	JOIN CITIES CITY ON SG.ID_CITY = CITY.ID
	JOIN STATUSAPPLICATIONS SA ON A.ID_STATUSAPPLICATIONS = SA.ID
	JOIN ACCOUNTS ACC ON C.ID_ACCOUNT = ACC.ID;

CREATE VIEW V_APPLICATIONS_DETAILS AS
SELECT
	A.ID AS APPLICATION_ID,
	A.FIRSTNAME,
	A.LASTNAME,
	A.SURNAME,
	A.PHONE,
	A.BIRTHDAY,
	A.EMAIL,
	A.ID_STATUSAPPLICATIONS,
	A.CREATED_AT,
	SG.ID AS STUDYGROUP_ID,
	SG.ENROLLMENT,
	SG.DATE_START,
	SG.PRICE,
	SG.DURATION,
	FT.NAME AS FORM_TRAINING_NAME,
	C.NAME AS CITY_NAME,
	CO.ID AS COURSE_ID,
	CO.NAME
FROM
	APPLICATIONS A
	JOIN STUDYGROUPS SG ON A.ID_STUDYGROUP = SG.ID
	LEFT JOIN FORMSTRAINING FT ON SG.ID_FORMSTRAINING = FT.ID
	LEFT JOIN CITIES C ON SG.ID_CITY = C.ID
	JOIN COURSES CO ON SG.ID_COURSE = CO.ID;

CREATE OR REPLACE VIEW COURSEANDGROUPVIEW AS
SELECT
	C.ID AS COURSE_ID,
	C.NAME AS COURSE_NAME,
	C.DESCRIPTION AS COURSE_DESCRIPTION,
	SEC.ID AS SECTION_ID,
	SEC.NAME AS SECTION_NAME,
	CR.NAME AS CREATOR_NAME,
	CR.EMAIL AS CREATOR_EMAIL,
	CR.PHONE AS CREATOR_PHONE,
	CR.IS_ORGANIZATION AS CREATOR_IS_ORGANIZATION,
	SG.ID AS GROUP_ID,
	SG.ENROLLMENT AS GROUP_ENROLLMENT,
	SG.DATE_START AS GROUP_DATE_START,
	SG.PRICE AS GROUP_PRICE,
	SG.DURATION AS GROUP_DURATION,
	COUNT_ACCEPTED_APPLICATIONS (SG.ID) AS ACCEPTED_APPLICATIONS_COUNT,
	GET_SCHEDULE_DAYS (SG.ID) AS SCHEDULE_DAYS,
	C.COURSE_CLOSED AS COURSE_CLOSED,
	FT.NAME AS FORM_TRAINING_NAME,
	CITY.NAME AS CITY_NAME
FROM
	COURSES C
	JOIN STUDYGROUPS SG ON C.ID = SG.ID_COURSE
	JOIN ACCOUNTS CR ON C.ID_ACCOUNT = CR.ID
	JOIN SECTIONS SEC ON SEC.ID = C.ID_SECTION
	JOIN FORMSTRAINING FT ON SG.ID_FORMSTRAINING = FT.ID
	JOIN CITIES CITY ON SG.ID_CITY = CITY.ID;

CREATE VIEW COURSESPERSECTION AS
SELECT
	S.NAME AS SECTION_NAME,
	COUNT(C.ID) AS COURSE_COUNT
FROM
	SECTIONS S
	LEFT JOIN COURSES C ON S.ID = C.ID_SECTION
GROUP BY
	S.NAME;

CREATE OR REPLACE VIEW APPLICATION_DETAILS_VIEW AS
SELECT
	A.ID AS APPLICATIONID,
	A.ID_STUDYGROUP AS GROUPID,
	SG.ID_COURSE AS COURSEID,
	C.NAME AS COURSENAME,
	SG.ID_FORMSTRAINING AS TRAININGFORMID,
	TF.NAME AS TRAININGFORMNAME,
	SG.ID_CITY AS CITYID,
	CT.NAME AS CITYNAME,
	A.ID_STATUSAPPLICATIONS AS APPLICATIONSTATUSID,
	SA.NAME AS APPLICATIONSTATUSNAME,
	A.EMAIL AS APPLICANTEMAIL,
	U.ID AS CREATORPROFILEID,
	U.EMAIL AS CREATOREMAIL,
	U.PHONE AS CREATORPHONE
FROM
	APPLICATIONS A
	JOIN STUDYGROUPS SG ON A.ID_STUDYGROUP = SG.ID
	JOIN COURSES C ON SG.ID_COURSE = C.ID
	JOIN FORMSTRAINING TF ON SG.ID_FORMSTRAINING = TF.ID
	JOIN CITIES CT ON SG.ID_CITY = CT.ID
	JOIN STATUSAPPLICATIONS SA ON A.ID_STATUSAPPLICATIONS = SA.ID
	JOIN ACCOUNTS U ON C.ID_ACCOUNT = U.ID;

SELECT
	*
FROM
	APPLICATION_DETAILS_VIEW;

CREATE OR REPLACE VIEW STUDYGROUPSVIEW AS
SELECT
	SG.ID,
	SG.ENROLLMENT,
	SG.DATE_START,
	SG.PRICE,
	SG.ID_FORMSTRAINING,
	SG.ID_CITY,
	SG.DURATION,
	SG.ID_COURSE,
	COUNT_ACCEPTED_APPLICATIONS (SG.ID) AS ACCEPTED_APPLICATIONS_COUNT,
	GET_SCHEDULE_DAYS (SG.ID) AS SCHEDULE_DAYS,
	FT.NAME AS FORM_TRAINING_NAME,
	CITY.NAME AS CITY_NAME
FROM
	STUDYGROUPS SG
	JOIN FORMSTRAINING FT ON SG.ID_FORMSTRAINING = FT.ID
	JOIN CITIES CITY ON SG.ID_CITY = CITY.ID
	JOIN COURSES C ON SG.ID_COURSE = C.ID;

CREATE VIEW CATEGORYSECTIONS AS
SELECT
	C.ID AS CATEGORYID,
	C.NAME AS CATEGORY,
	S.ID AS SECTIONID,
	S.NAME AS SUBSECTION
FROM
	CATEGORIES C
	JOIN SECTIONS S ON C.ID = S.ID_CATEGORY;

SELECT
	*
FROM
	CATEGORYSECTIONS;

CREATE OR REPLACE VIEW COURSEVIEW AS
SELECT
	C.ID AS CATEGORYID,
	C.NAME AS CATEGORYNAME,
	S.ID AS SECTIONID,
	S.NAME AS SECTIONNAME,
	CR.ID AS COURSEID,
	CR.NAME AS COURSENAME,
	CR.DESCRIPTION AS COURSEDESCRIPTION,
	CR.CREATED_AT AS COURSECREATEDAT,
	CR.COURSE_CLOSED AS COURSECLOSED,
	AC.ID AS ACCOUNTID
FROM
	CATEGORIES C
	JOIN SECTIONS S ON C.ID = S.ID_CATEGORY
	JOIN COURSES CR ON S.ID = CR.ID_SECTION
	JOIN ACCOUNTS AC ON AC.ID = CR.ID_ACCOUNT;

CREATE VIEW USERPROFILEINFO AS
SELECT
	A.ID AS ACCOUNT_ID,
	A.EMAIL,
	A.PHONE,
	A.NAME,
	A.ABOUT_ME,
	A.LICENSE_NUMBER,
	A.CONFIRMATION,
	A.CREATED_AT AS ACCOUNT_CREATED_AT
FROM
	ACCOUNTS A;

CREATE
OR REPLACE FUNCTION GET_USER_PROFILE_INFO (P_PROFILE_ID INTEGER) RETURNS USERPROFILEINFO AS $$
DECLARE
    user_profile UserProfileInfo;
BEGIN
    SELECT * INTO user_profile
    FROM UserProfileInfo
    WHERE account_id = p_profile_id;

    RETURN user_profile;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_USER_PROFILE (
	P_USER_ID INTEGER,
	P_NAME VARCHAR,
	P_ABOUT_ME VARCHAR,
	P_EMAIL VARCHAR,
	P_PHONE VARCHAR
) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION LOGIN_ADMIN (
	P_LOGIN VARCHAR,
	P_PASSWORD VARCHAR,
	OUT RESULT_ID INTEGER
) AS $$
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

CREATE
OR REPLACE FUNCTION REGISTER_PROFILE (
	P_NAME VARCHAR,
	P_LICENSE_NUMBER VARCHAR,
	P_EMAIL VARCHAR,
	P_PASSWORD VARCHAR,
	P_IS_ORGANIZATION BOOL,
	P_PHONE VARCHAR
) RETURNS INTEGER AS $$
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
    
--EXCEPTION
    --WHEN OTHERS THEN
        -- Возвращаем код ошибки
        --RETURN 0;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION LOGIN_USER (P_EMAIL VARCHAR, P_PASSWORD VARCHAR) RETURNS INTEGER AS $$
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

CREATE
OR REPLACE FUNCTION GETAPPLICATIONDETAILS (APPLICATIONID INT) RETURNS SETOF APPLICATIONDETAILSVIEW AS $$
BEGIN
    RETURN QUERY 
    SELECT *
    FROM 
        ApplicationDetailsView ad
    WHERE 
        ad.application_id = applicationId;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CHECK_ACCOUNT_CONFIRMATION (P_USER_ID INTEGER) RETURNS BOOLEAN AS $$
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

CREATE
OR REPLACE FUNCTION GET_COURSES_PERSECTION () RETURNS SETOF COURSESPERSECTION AS $$
BEGIN
    RETURN QUERY
    SELECT
	*
    FROM
        CoursesPerSection;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION IS_COURSE_BANNED (P_COURSE_ID INTEGER) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION ADD_BAN (
	P_COURSE_ID INTEGER,
	P_ADMIN_ID INTEGER,
	P_REASON TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_ban_id INTEGER;
BEGIN
    -- Вставляем новую запись в таблицу BannedCourses
    INSERT INTO BANNEDCOURSES (id_Course, id_Administrator, cause)
    VALUES (p_course_id, p_admin_id, p_reason)
    RETURNING id INTO v_ban_id;

    -- В случае успешной вставки возвращаем id записи
    RETURN v_ban_id;
EXCEPTION
    WHEN OTHERS THEN
        -- В случае ошибки возвращаем 0
        RETURN 0;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION DELETE_BAN_BY_COURSE_ID (P_COURSE_ID INTEGER) RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM BANNEDCOURSES WHERE id_Course = p_course_id;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
--EXCEPTION
    --WHEN OTHERS THEN
        --RETURN FALSE;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CAN_EDIT_COURSE (PROFILE_ID INTEGER, COURSE_ID INTEGER) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_CATEGORIES_WITH_SUBSECTIONS () RETURNS TABLE (CATEGORY_NAME VARCHAR, SUBSECTIONS JSONB) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS category_name,
        jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name)) AS subsections
    FROM
        categories c
    LEFT JOIN
        Sections s ON c.id = s.id_category
    GROUP BY
        c.id, c.name;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CREATE_COURSE (
	P_PROFILE_ID INTEGER,
	P_COURSE_NAME VARCHAR,
	P_SECTION_ID INTEGER,
	P_DESCRIPTION VARCHAR
) RETURNS INTEGER AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_COURSE (
	P_COURSE_ID INTEGER,
	P_COURSE_NAME VARCHAR,
	P_SECTION_ID INTEGER,
	P_DESCRIPTION VARCHAR,
	P_COURSE_CLOSED BOOLEAN
) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_COURSE_INFO (COURSE_ID INTEGER) RETURNS COURSEVIEW AS $$
DECLARE
    course_info CourseView;
BEGIN
    SELECT * INTO course_info FROM CourseView WHERE courseid = get_course_info.course_id;
    RETURN course_info;
END;
$$ LANGUAGE PLPGSQL;

SELECT
	*
FROM
	COURSEVIEW;

SELECT
	*
FROM
	GET_COURSE_INFO (10);

CREATE
OR REPLACE FUNCTION GET_COURSES_BY_PROFILE (PROFILE_ID INTEGER) RETURNS SETOF COURSEVIEW AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE PROCEDURE DELETECOURSE (COURSEID INT) AS $$
BEGIN
    DELETE FROM Courses WHERE id = courseId;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CREATE_STUDY_GROUP (
	P_ENROLLMENT INTEGER,
	P_DATE_START DATE,
	P_PRICE NUMERIC(10, 2),
	P_ID_FORMSTRAINING INTEGER,
	P_ID_CITY INTEGER,
	P_DURATION INTEGER,
	P_ID_COURSE INTEGER
) RETURNS INTEGER AS $$
DECLARE
    new_group_id INTEGER;
BEGIN
    BEGIN
        INSERT INTO studygroups (enrollment, date_start, price, id_FormsTraining, id_city, duration, id_course)
        VALUES (p_enrollment, p_date_start, p_price, p_id_FormsTraining, p_id_city, p_duration, p_id_course)
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_STUDY_GROUP (
	P_ID INTEGER,
	P_ENROLLMENT INTEGER,
	P_DATE_START DATE,
	P_PRICE NUMERIC(10, 2),
	P_ID_FORMS_TRAINING INTEGER,
	P_ID_CITY INTEGER,
	P_DURATION INTEGER
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE studygroups
    SET 
        enrollment = p_enrollment,
        date_start = p_date_start,
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_COURSE_INSTANCES (P_COURSE_ID INTEGER) RETURNS SETOF COURSEANDGROUPVIEW AS $$
BEGIN
  RETURN QUERY
  SELECT
	*
  FROM
    CourseAndGroupView c
  WHERE
    c.course_id = p_course_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION FILTER_COURSES_AND_GROUPS (
	P_SECTION_ID INTEGER,
	P_START_DATE DATE DEFAULT NULL,
	P_MIN_PRICE NUMERIC(10, 2) DEFAULT NULL,
	P_MAX_PRICE NUMERIC(10, 2) DEFAULT NULL,
	P_ORGANIZATION_ONLY BOOLEAN DEFAULT FALSE,
	P_FREE_ONLY BOOLEAN DEFAULT FALSE,
	P_SEARCH_QUERY VARCHAR DEFAULT NULL
) RETURNS SETOF COURSEANDGROUPVIEW AS $$
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


    IF p_min_price IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_price >= ' || p_min_price;
    END IF;

    IF p_max_price IS NOT NULL THEN
        filter_conditions := filter_conditions || ' AND group_price <= ' || p_max_price;
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_ALL_FORMS_TRAINING () RETURNS TABLE (FORM_ID INT, FORM_NAME VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY SELECT id AS form_id, name AS form_name FROM FormsTraining;
END;
$$ LANGUAGE PLPGSQL;

-- Функция для вывода всех данных из таблицы Cities
CREATE
OR REPLACE FUNCTION GET_ALL_CITIES () RETURNS TABLE (CITY_ID INT, CITY_NAME VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY SELECT id AS city_id, name AS city_name FROM Cities;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_STUDY_GROUPS_BY_COURSE_ID (P_COURSE_ID INTEGER) RETURNS SETOF STUDYGROUPSVIEW AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id_course = p_course_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_STUDY_GROUPS_BY_CREATER_ID (P_CREATER_ID INTEGER) RETURNS SETOF STUDYGROUPSVIEW AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id = p_creater_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_STUDY_GROUP_BY_ID (P_GROUP_ID INTEGER) RETURNS SETOF STUDYGROUPSVIEW AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id = p_group_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION DELETE_STUDY_GROUP_BY_ID (P_GROUP_ID INTEGER) RETURNS INTEGER AS $$
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

CREATE
OR REPLACE FUNCTION GETCOURSEAPPLICATIONSSTATISTICSBYCREATORID (P_CREATOR_ID INTEGER) RETURNS SETOF APPLICATIONSPERCOURSE AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM ApplicationsPerCourse
    WHERE creator_id = p_creator_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CREATE_APPLICATION (
	P_ID_STUDYGROUP INTEGER,
	P_FIRSTNAME VARCHAR(60),
	P_LASTNAME VARCHAR(60),
	P_SURNAME VARCHAR(60),
	P_PHONE VARCHAR(15),
	P_BIRTHDAY DATE,
	P_EMAIL VARCHAR(255)
) RETURNS INTEGER AS $$
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
--EXCEPTION
    --WHEN others THEN
       -- RETURN 0;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_APPLICATION_STATUS (P_APPLICATION_ID INTEGER, P_NEW_STATUS_ID INTEGER) RETURNS BOOLEAN AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_APPLICATIONS (
	P_ID_COURSE INTEGER,
	P_ID_STATUS INTEGER DEFAULT NULL
) RETURNS SETOF V_APPLICATIONS_DETAILS AS $$
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION CREATE_PROGRAM_COURSE (
	P_NAME VARCHAR,
	P_DESCRIPTION VARCHAR,
	P_ID_COURSE INTEGER
) RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    -- Проверяем, существует ли курс с указанным ID
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE id = p_id_course) THEN
        RETURN -1; -- Курс не найден
    END IF;

    -- Вставляем новую запись в таблицу ProgramsCourse
    INSERT INTO PROGRAMSCOURSE (name, description, id_course)
    VALUES (p_name, p_description, p_id_course)
    RETURNING id INTO new_id;

    RETURN new_id; -- Возвращаем ID созданной программы

EXCEPTION
    WHEN others THEN
        RETURN 0; -- Произошла ошибка
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_PROGRAMS_BY_COURSE_ID (P_COURSE_ID INTEGER) RETURNS SETOF PROGRAMSCOURSE AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM 
        PROGRAMSCOURSE pg
    WHERE 
        pg.id_course = p_course_id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_PROGRAM_COURSE (
	P_ID INTEGER,
	P_NAME VARCHAR(255),
	P_DESCRIPTION VARCHAR(255)
) RETURNS BOOLEAN AS $$
DECLARE
    success BOOLEAN := FALSE;
BEGIN
    BEGIN
        UPDATE PROGRAMSCOURSE
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
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_USER_PROFILES_INFO () RETURNS SETOF USERPROFILEINFO AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM
        UserProfileInfo;
END;
$$ LANGUAGE PLPGSQL;


CREATE
OR REPLACE FUNCTION GET_ALL_BANNED_COURSES () RETURNS TABLE (
	ID INTEGER,
	CAUSE VARCHAR,
	ID_COURSE INTEGER,
	COURSE_NAME VARCHAR,
	ID_ADMINISTRATOR INTEGER,
	ADMIN_NAME VARCHAR,
	BANNED_AT TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    bc.id,
    bc.cause,
    bc.id_course,
    c.name,
    bc.id,
    a.name,
    bc.banned_at
  FROM 
    BannedCourses bc
  LEFT JOIN
    Courses c ON bc.id_course = c.id
  LEFT JOIN
    Accounts a ON bc.id_administrator = a.id;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_ACCOUNT_CONFIRMATION (P_ACCOUNT_ID INTEGER, P_NEW_CONFIRMATION BOOLEAN) RETURNS BOOLEAN AS $$
DECLARE
    updated_rows INTEGER;
BEGIN
    -- Пытаемся обновить подтверждение профиля
    UPDATE Accounts SET confirmation = p_new_confirmation WHERE id = p_account_id RETURNING id INTO updated_rows;

    -- Если количество обновленных строк больше 0, значит обновление прошло успешно
    IF updated_rows > 0 THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION GET_ALL_SECTIONS () RETURNS TABLE (SECTION_ID INTEGER, SECTION_NAME VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT id, name FROM Sections;
END;
$$ LANGUAGE PLPGSQL;