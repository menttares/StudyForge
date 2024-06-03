-- Заполнение таблицы "Categories"
INSERT INTO Сategories (name) VALUES
('Технологии'),
('Искусство'),
('Наука'),
('Спорт'),
('Музыка'),
('Еда');

-- Заполнение таблицы "Sections"
INSERT INTO Sections (id_category, name) VALUES
(1, 'Программирование'),
(1, 'Аппаратное обеспечение'),
(1, 'Сетевые технологии'),
(2, 'Живопись'),
(2, 'Скульптура'),
(2, 'Фотография'),
(3, 'Физика'),
(3, 'Биология'),
(3, 'Химия'),
(4, 'Футбол'),
(4, 'Баскетбол'),
(4, 'Теннис'),
(5, 'Рок'),
(5, 'Джаз'),
(5, 'Классика'),
(6, 'Итальянская'),
(6, 'Французская'),
(6, 'Японская');


-- Вставка данных в таблицу Specializations
INSERT INTO Specializations (name) VALUES 
    ('IT-технологии'),
    ('Промышленность'),
    ('Медицина'),
    ('Образование'),
    ('Искусство'),
    ('Финансы');

-- форма обучения
INSERT INTO FormsTraining (name) VALUES 
('Очная'),
('Заочная'),
('Очно-заочная');

-- города РБ и другие
INSERT INTO Cities (name) VALUES 
('Минск'),
('Гомель'),
('Могилев'),
('Витебск'),
('Гродно'),
('Брест'),
('Мозырь'),
('Бобруйск'),
('Полоцк');

select * from 

-- Регистрация новых аккаунтов
SELECT * FROM register_profile('John Doe', '011234567812', 'john@example.com', 'password123', FALSE, '+375297418358');
SELECT * FROM register_profile('Alice Smith', '021234567813', 'alice@example.com', 'password456', FALSE, '+375297418258');
SELECT * FROM register_profile('TechNate', '031234567814', 'bob@example.com', 'password789', TRUE, '+375297418359');

select * from accounts;
-- Изменение данных первой учетной записи
SELECT * FROM update_user_profile(2, 'Alice Smith', 'Описание', 2);


SELECT * FROM get_user_profile_info(9);

SELECT * FROM create_course(3, 'Тест6', 2, 'описание');
SELECT * FROM can_edit_course(1,2);

SELECT * FROM update_course(2, 'Тест2', 2, 'описание');

SELECT * FROM get_course_info(6);


SELECT create_study_group(null, null, null, null, null, null, null, 10);

select * from studygroups;

SELECT update_study_group(
    2, -- ID учебной группы для обновления
    25, -- Новое количество студентов в группе
    '2024-04-31', -- Новая дата начала набора
    '2024-08-31', -- Новая дата окончания набора
    150.00, -- Новая цена
    2, -- Новый ID формы обучения
    3, -- Новый ID города
    120 -- Новая продолжительность в часах
);


SELECT create_application(
    2, -- ID учебной группы
    'Иван', -- Имя
    'Петров', -- Фамилия
    'Сергеевич', -- Отчество (если есть)
    '+375291234567', -- Номер телефона
    '2000-01-01', -- Дата рождения
	'emial@gmail.com'
);

select * from applications;

select update_application_status(3,1);

select count_accepted_applications(2);

select get_schedule_days(4);

SELECT update_schedule_days(8, ARRAY[1,2,3,4]::integer[]);

select * from timeslot_StudyGroups;


SELECT * FROM filter_courses_and_groups(
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null
);


select * from userprofileinfo;

