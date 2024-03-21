-- Создание таблицы "изображений профиля"
CREATE TABLE ImagesProfile (
	-- ID ключ
    id SERIAL PRIMARY KEY,
	-- Имя файла
    filename TEXT not null
);

-- Создание таблицы "Профиль"
CREATE TABLE profile (
  -- ID профиля (рукописный ключ)
  id SERIAL PRIMARY KEY,

  -- ID аватара/фото профиля (ссылка на таблицу ImagesProfile)
  id_ImagesProfile INTEGER  null REFERENCES ImagesProfile(id) null,
	

  -- Почта (уникальная, не null, обязателен символ'@' в поле)
  email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%'),

  -- Пароль (5-20 символов, без пробелов, только цифры, буквы, спецсимволы)
  password VARCHAR(20) NOT NULL CHECK (password ~ '^[a-zA-z\d\@\+\\#!-]{5,20}$'),

  -- Организация, true - является юридическим лицом, иначе физическое - false
  is_organization BOOL NULL DEFAULT 'false',

  -- Телефон, но только белорусский
  phone VARCHAR(255) NOT NULL check (phone ~ '^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$'),

  -- Имя человека или организации (не null, минимум 3 символа и максимум 40)
  name VARCHAR(255) NOT NULL CHECK (LENGTH(name) >= 3 and LENGTH(name) <= 40),

  -- О себе (необязательное поле)
  about_me TEXT NULL,

  -- Специализация, сфера работы организации (например, IT-технологии, промышленность)
  -- или специальность человека(Например, техник-программист, экономист)
  specialization VARCHAR(255) NULL,

  -- Номер лицензии РБ (Обязательное поле)
  license_number VARCHAR(255) UNIQUE not null check (license_number ~ '^(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20)\d{2}\d{6}\d{2}$'),


  -- Дата подтверждения профиля администратором (необязательное поле, т.к. это поле будет проверено в будущем администратором)
  confirmation bool NULL,

  -- Дата создания профиля (автоматически заполняется)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from profile;

-- Создание таблицы "Категория"
CREATE TABLE category (
  -- ID
  id SERIAL PRIMARY KEY,
  -- Название Категории
  name VARCHAR(255) NOT NULL
);

-- Создание таблицы "Раздел"
CREATE TABLE section (
  -- ID
  id SERIAL PRIMARY KEY,
  -- FK ключ к разделу, к котору относится раздел
  id_category INTEGER REFERENCES category(id) not null,
  -- Название Раздела
  name VARCHAR(255) NOT NULL
);


-- фото преподавателя
CREATE TABLE teacherAvatar (
  id SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL
);

-- Создание таблицы курсов
CREATE TABLE courses (
  -- ID курса
  id SERIAL PRIMARY KEY,
  -- категория, к которому относится курс
  id_section INTEGER REFERENCES section(id) not null,
  -- создатель курса
  id_profile INTEGER REFERENCES profile(id) not null,
  -- Название курса
  name VARCHAR(60) NOT NULL check(
    LENGTH(name) >= 3
    and LENGTH(name) <= 60
  ),
  -- Описание курса
  description varchar(500) NULL,
  -- Дата создания (автоматически заполняется)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- закрыт ли курс организатором?
  course_closed bool DEFAULT FALSE
);

-- преподаватель
CREATE TABLE teacher (
  id SERIAL PRIMARY KEY,
  id_course INTEGER REFERENCES courses(id) not null,
	-- необязательно
  id_Avatar INTEGER REFERENCES teacherAvatar(id) Null,
  FirstName VARCHAR(255) NOT NULL,
  AboutMe VARCHAR(500) NULL,
  Skills VARCHAR(255) NULL,
  Specialization VARCHAR(255) NULL
);

-- создание программы курса
CREATE TABLE program_course (
  -- ID 
  id SERIAL PRIMARY KEY,
  -- Название курса
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  id_course INTEGER REFERENCES courses(id) not null
);

-- дни, таблица не будет никогда заполнятся, определяется всегда вначале создания БД
CREATE TABLE days (
  id SERIAL PRIMARY KEY,
  Name VARCHAR(30) NOT NULL
);

-- форма обучения
CREATE TABLE form_study (
  id SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL
);

-- города РБ и другие
CREATE TABLE city (
  ID SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL
);

-- учебная группа
CREATE TABLE study_group (
  id serial PRIMARY KEY,
  -- набор
  enrollment integer not NULL check (enrollment > 0),
  -- дата начала набора
  date_start date not NULL,
  -- дата окончания набора (необязательно)
  date_end date NULL CHECK (
    date_end >= date_start
    OR date_end IS NULL
  ),
	-- цена
  price numeric(10, 2) null check (
    price > 0
    and price < 10000000
  ),
	-- форма обучения
  id_form_study integer REFERENCES form_study(id) NOT NULL,
	-- город 
  id_city integer REFERENCES city(id) NULL,
  -- длительность в часах
  duration integer NULL check (duration > 0),

  id_course INTEGER REFERENCES courses(id) null
);


-- создаем список учебных дней группы
create table timeslot_study_group (
  id SERIAL PRIMARY KEY,
  id_day INTEGER REFERENCES days(id) not null,
  id_study_group INTEGER REFERENCES study_group(id) not null
);



-- статус заявки 
create table status_applications (
  id SERIAL PRIMARY KEY,
  Name VARCHAR(255) NOT NULL
);


-- заявки 
create table applications(
  id SERIAL PRIMARY KEY,
  id_study_group INTEGER REFERENCES study_group(id) not null,
  FirstName VARCHAR(255) NOT NULL,
  phone VARCHAR(255) NOT NULL check (
    phone ~ '^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$'
  ),
  -- Проверка пользователя, что ему есть 18 и не будущая дата
  birthday date not null CHECK (
    EXTRACT(
      YEAR
      FROM CURRENT_DATE
    ) - EXTRACT(
      YEAR
      FROM birthday
    ) >= 18
    and birthday < CURRENT_DATE
  ),
	
  id_status_applications INTEGER REFERENCES status_applications(id) not null
);


-- администраторы платформы
create table admins (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) check (
    LENGTH(name) >= 3
    and LENGTH(name) < 100
  ),
  login VARCHAR(50) NOT NULL check (login ~ '^[a-zA-z\d\@\+\\#!-]{5,20}$'),
  password varchar(50) NOT NULL check (login ~ '^[a-zA-z\d\@\+\\#!-]{5,20}$')
);

------------------
-- вставка данных
------------------
INSERT INTO profile (
  email,
  password,
  is_organization,
  phone,
  name,
  about_me,
  specialization,
  license_number,
  confirmation
)
VALUES
  ('user1@example.com', 'password123', FALSE, '+375291234567', 'Иван', 'О себе', 'Программирование', '012300000123', TRUE),
  ('user2@example.com', 'password456', TRUE, '+375298674522', 'РосТех', 'Организация по разработке IT-технологий', 'IT-технологии, логистика', '012300000125', TRUE),
  ('user3@example.com', 'password789', FALSE, '+375331234567', 'Петр', 'Интересуюсь спортом', 'Маркетинг', '022300000223', TRUE);
  
  

-- Заполнение таблицы "Категории"
INSERT INTO category (name) VALUES
('Наука и технологии'),
('Бизнес и маркетинг'),
('Творчество');

-- Заполнение таблицы "Разделов"
INSERT INTO section (id_category, name) VALUES
(1, 'Физика и астрономия'),
(1, 'Информационные технологии'),
(2, 'Менеджмент и лидерство'),
(2, 'Маркетинг и реклама'),
(3, 'Живопись и рисование'),
(3, 'Музыка и композиция');

select * from section;

-- (Также приведены псевдоданные для иллюстрации)
INSERT INTO courses (id_section, id_profile, name, description, course_closed) VALUES
(2, 1, 'Основы программирования на Python', 'Введение в Python для начинающих.', false),
(4, 2, 'Управление проектами', 'Основы управления проектами и командой.', true);



INSERT INTO teacher (id_course, id_Avatar, FirstName, AboutMe, Skills, Specialization) VALUES
(1, NULL, 'Петр Петров', 'Профессиональный программист с опытом работы более 10 лет.', 'Python, Java, C++', 'Программирование'),
(2, NULL, 'Анна Сидорова', 'Специалист в области управления проектами и бизнес-анализа.', 'Управление проектами, аналитика', 'Менеджмент');

INSERT INTO program_course (name, description, id_course) VALUES
('Введение в Python', 'Основы синтаксиса и основные конструкции языка Python.', 1),
('Алгоритмы в Python', 'Основы алгоритмов.', 1),
('WEb в Python', 'основы web-технологий.', 1),
('Управление временем', 'Техники и инструменты для эффективного управления временем в проектах.', 2),
('Управление командой', 'Техники и инструменты для эффективного управления командой', 2);


INSERT INTO days (Name) VALUES
('ПН'),
('ВТ'),
('СР'),
('ЧТ'),
('ПТ'),
('СБ'),
('ВС');

INSERT INTO form_study (Name) VALUES
('Очная'),
('Дистанционная');

INSERT INTO city (Name) VALUES
( 'Минск'),
( 'Гомель'),
( 'Гродно');


INSERT INTO study_group (enrollment, date_start, date_end, price, id_form_study, id_city, duration, id_course) VALUES
(20, '2024-04-01', '2024-09-30', 1000, 1, 1, 60, 1),
(15, '2024-03-15', '2024-08-31', 800, 2, 2, 50, 2);


INSERT INTO study_group (enrollment, date_start, date_end, price, id_form_study, id_city, duration, id_course) VALUES
(10, '2024-01-01', '2024-03-24', 300, 1, 1, 60, 1),
(10, '2024-01-15', '2024-03-31', 100, 2, 2, 50, 2);


INSERT INTO timeslot_study_group(id_day, id_study_group) values 
(1,2),
(2,2),
(3,2),
(4,2),
(1,1),
(2,1),
(3,1),
(6,1);

INSERT INTO status_applications (Name)
VALUES 
('Принято'),
('Отклонено'),
('В ожидании');




select * from status_applications;

INSERT INTO applications (id_study_group, FirstName, phone, birthday, id_status_applications)
VALUES 
(1, 'Иван', '+375291234567', '1995-05-15', 1),
(1, 'Мария', '+375291234568', '1996-08-21', 2),
(1, 'Алексей', '+375291234569', '1998-03-10', 3),
(1, 'Елена', '+375291234570', '1994-11-27', 1);

-- Вставка примеров заявок для группы с ID = 2
INSERT INTO applications (id_study_group, FirstName, phone, birthday, id_status_applications)
VALUES 
(2, 'Дмитрий', '+375291234571', '1997-02-18', 1),
(2, 'Ольга', '+375291234572', '1993-09-05', 2),
(2, 'Павел', '+375291234573', '1999-06-30', 2),
(2, 'Наталья', '+375291234574', '1990-12-14', 1);




select * from form_study;




-- Вставка новых курсов
INSERT INTO courses (id_section, id_profile, name, description, course_closed) VALUES
(1, 1, 'Космология и звезды', 'Изучение основ космологии и астрофизики.', false),
(1, 3, 'Астрономия для начинающих', 'Введение в мир звезд и планет для новичков.', false),
(2, 1, 'Алгоритмы и структуры данных', 'Глубокое погружение в алгоритмы и их структуры.', false),
(2, 3, 'Веб-разработка на JavaScript', 'Освоение современных технологий веб-разработки с использованием JavaScript.', false),
(3, 2, 'Основы акриловой живописи', 'Практические занятия по освоению техник акриловой живописи.', false),
(3, 2, 'Музыкальная композиция', 'Изучение основ музыкальной композиции и создание собственных мелодий.', false);

select * from courses;
-- Вставка новых преподавателей
INSERT INTO teacher (id_course, id_Avatar, FirstName, AboutMe, Skills, Specialization) VALUES
(12, NULL, 'Елена Иванова', 'Преподаватель с опытом в области алгоритмов и программирования.', 'Python, Java, C', 'Программирование'),
(12, NULL, 'Михаил Сидоров', 'Опытный веб-разработчик, готовый поделиться своими знаниями.', 'JavaScript, HTML, CSS', 'Веб-разработка');

-- Вставка новой программы курса
INSERT INTO program_course (name, description, id_course) VALUES
('Звезды и галактики', 'Изучение строения и жизненного цикла звезд, а также галактик.', 3),
('Путешествие по Солнечной системе', 'Познание планет и других объектов Солнечной системы.', 3),
('Структуры данных в JS', 'Глубокий анализ структур данных и их применение на языке JS.', 6),
('Мастер-класс по веб-разработке', 'Практические занятия по созданию веб-приложений с использованием современных инструментов.', 1);

-- Вставка новых учебных групп
INSERT INTO study_group (enrollment, date_start, date_end, price, id_form_study, id_city, duration, id_course) VALUES
(25, '2024-04-15', '2024-10-15', 400, 1, 1, 70, 5),
(18, '2024-05-01', '2024-09-01', 400, 1, 2, 60, 6),
(12, '2024-06-01', '2024-11-30', 100, 2, 1, 50, 7);

-- Вставка новых временных слотов для учебных групп
INSERT INTO timeslot_study_group(id_day, id_study_group) VALUES 
(1,3),
(2,3),
(3,3),
(4,3),
(5,3),
(6,3),
(7,3),
(1,4),
(2,4),
(3,4),
(4,4),
(5,4),
(6,4),
(7,4),
(1,5),
(2,5),
(3,5),
(4,5),
(5,5),
(6,5),
(7,5);








