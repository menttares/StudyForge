-- Создание типа ENUM для статусов заявок
CREATE TYPE STATUS_ENUM AS ENUM('принято', 'отклонено', 'ожидание');

-- Таблица ImagesProfile
CREATE TABLE IMAGESPROFILE (
	ID SERIAL PRIMARY KEY, -- ID ключ
	FILENAME VARCHAR(100) UNIQUE NOT NULL -- Имя файла
);

-- Таблица Accounts
CREATE TABLE ACCOUNTS (
	ID SERIAL PRIMARY KEY, -- ID профиля (рукописный ключ)
	ID_IMAGESPROFILE INTEGER REFERENCES IMAGESPROFILE (ID) ON DELETE SET NULL, -- ID аватара/фото профиля
	EMAIL VARCHAR(100) UNIQUE NOT NULL CHECK (EMAIL LIKE '%@%'), -- Почта (уникальная, не null, обязателен символ'@' в поле)
	PASSWORD VARCHAR(20) NOT NULL CHECK (PASSWORD ~ '^[a-zA-Z\\d@+#\\!]{5,20}$'), -- Пароль (5-20 символов, без пробелов, только цифры, буквы, спецсимволы)
	IS_ORGANIZATION BOOL DEFAULT 'false', -- Организация, true - является юридическим лицом, иначе физическое - false
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
	) DEFAULT 0, -- Цена обучения
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
    ip.filename AS profile_image,
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
    Accounts a
LEFT JOIN 
    ImagesProfile ip ON a.id_ImagesProfile = ip.id;



