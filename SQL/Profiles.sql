CREATE TABLE ImagesProfile (
	-- ID ключ
    id SERIAL PRIMARY KEY,
	-- Имя файла
    filename TEXT UNIQUE not null
);

-- специализация профиля/преподавателя
CREATE TABLE Specializations (
	-- ID ключ
    id SERIAL PRIMARY KEY,
	-- Имя специальности
    name varchar(100) UNIQUE not null
);

select * from Accounts;

CREATE OR REPLACE FUNCTION get_all_specializations()
RETURNS TABLE (
    specialization_id INTEGER,
    specialization_name VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY SELECT id, name FROM Specializations;
END;
$$ LANGUAGE PLPGSQL;

select get_all_specializations();

-- аккаунт организатора курса
CREATE TABLE Accounts (
  -- ID профиля (рукописный ключ)
  id SERIAL PRIMARY KEY,

  -- ID аватара/фото профиля (ссылка на таблицу ImagesProfile)
  id_ImagesProfile INTEGER  null REFERENCES ImagesProfile(id) ON DELETE SET NULL,
	

  -- Почта (уникальная, не null, обязателен символ'@' в поле)
  email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%'),

  -- Пароль (5-20 символов, без пробелов, только цифры, буквы, спецсимволы)
  password VARCHAR(20) NOT NULL CHECK (password ~ '^[a-zA-z\d\@\+\\#!-]{5,20}$'),

  -- Организация, true - является юридическим лицом, иначе физическое - false
  is_organization BOOL NULL DEFAULT 'false',

  -- Телефон, но только белорусский
  phone VARCHAR(255) UNIQUE NOT NULL check (phone ~ '^(\+375)(29|33|44|25|17)(\d{3})(\d{2})(\d{2})$'),

  -- Имя человека или организации (не null, минимум 3 символа и максимум 40)
  name VARCHAR(255) NOT NULL CHECK (LENGTH(name) >= 3 and LENGTH(name) <= 40),

  -- О себе (необязательное поле)
  about_me VARCHAR(200) NULL,

  -- Специализация, сфера работы организации (например, IT-технологии, промышленность)
  -- или специальность человека(Например, техник-программист, экономист)
  specialization INTEGER  null REFERENCES Specializations(id) ON DELETE SET NULL,

  -- Номер лицензии РБ (Обязательное поле)
  license_number VARCHAR(255) UNIQUE not null check (license_number ~ '^(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20)\d{2}\d{6}\d{2}$'),


  -- поле подтверждения профиля администратором (необязательное поле, т.к. это поле будет проверено в будущем администратором)
  confirmation bool DEFAULT False,

  -- Дата создания профиля (автоматически заполняется)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



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


select * from check_account_confirmation(4);


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

select * from ApplicationDetailsView;


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



-- администратор платформы
create table Administrators (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) check (
    LENGTH(name) >= 3
    and LENGTH(name) < 100
  ),
  email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%'),
  password varchar(50) NOT NULL check (password ~ '^[a-zA-z\d\@\+\\#!-]{5,20}$')
);

insert into Administrators(name, email, password ) values
	(
		'Менеджер', 'menttare.h@gmail.com', 'admin@542'
	);

select * from Administrators;
-- ===================================================================================================
-- ===================================================================================================
-- ===================================================================================================
-- ===================================================================================================

CREATE OR REPLACE FUNCTION login_user(p_email VARCHAR, p_password VARCHAR, OUT result_id INTEGER, OUT error_message TEXT) 
AS $$
DECLARE
    user_id INTEGER;
    stored_password VARCHAR;
BEGIN
    -- Проверяем, существует ли пользователь с указанным email
    SELECT id, password INTO user_id, stored_password FROM Accounts WHERE email = p_email LIMIT 1;

    -- Если email не найден, возвращаем -1
    IF user_id IS NULL THEN
        result_id := -1;
        error_message := 'Пользователь с таким email не существует';
        RETURN;
    END IF;

    -- Проверяем совпадение паролей
    IF stored_password <> p_password THEN
        result_id := -2;
        error_message := 'Пароли не совпадают';
        RETURN;
    ELSE
        -- Если все проверки пройдены успешно, возвращаем id
        result_id := user_id;
        error_message := 'Вход выполнен успешно';
        RETURN;
    END IF;

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        result_id := 0;
        error_message := 'Произошла ошибка при входе пользователя: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION register_profile(
    p_name VARCHAR,
    p_license_number VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_is_organization BOOL,
    p_phone VARCHAR,
    OUT result_id INTEGER,
    OUT error_message TEXT
) 
AS $$
DECLARE
    inserted_id INTEGER;
BEGIN
    -- Проверяем, существует ли уже пользователь с таким email
SELECT id INTO result_id FROM Accounts WHERE email = p_email LIMIT 1;
    IF FOUND THEN
        result_id := -1;
        error_message := 'Пользователь с таким email уже существует';
        RETURN;
    END IF;
    
    -- Проверяем, существует ли уже пользователь с такой лицензией
    SELECT id INTO result_id FROM Accounts WHERE license_number = p_license_number LIMIT 1;
    IF FOUND THEN
        result_id := -3;
        error_message := 'Пользователь с таким license_number уже существует';
        RETURN;
    END IF;

	-- Проверяем, существует ли уже пользователь с таким телефоном
    SELECT id INTO result_id FROM Accounts WHERE phone = p_phone LIMIT 1;
    IF FOUND THEN
        result_id := -4;
        error_message := 'Пользователь с таким телефоном уже существует';
        RETURN;
    END IF;

    -- Добавляем новый профиль
    INSERT INTO Accounts (name, license_number, email, password, is_organization, phone)
    VALUES (p_name, p_license_number, p_email, p_password, p_is_organization, p_phone)
    RETURNING id INTO inserted_id;

    -- Возврат сообщения об успешной регистрации
    result_id := inserted_id;
    error_message := 'Регистрация успешна';
    
EXCEPTION
    WHEN OTHERS THEN
        -- Возвращаем сообщение об ошибке
        result_id := 0;
        error_message := 'Произошла ошибка при регистрации пользователя: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM register_profile(
    p_name := 'John Doe',
    p_license_number := '011234567312',
    p_email := 'john321@example.com',
    p_password := 'password123',
    p_is_organization := FALSE,
    p_phone := '+375293418258'
);








	

CREATE OR REPLACE FUNCTION login_admin(p_login VARCHAR, p_password VARCHAR, OUT result_id INTEGER, OUT error_message TEXT)
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
        error_message := 'Администратор с указанным email не найден';
        RETURN;
    END IF;

    -- Проверяем совпадение паролей
    IF stored_password <> p_password THEN
        result_id := -2;
        error_message := 'Неверный пароль';
        RETURN;
    ELSE
        -- Если все проверки пройдены успешно, возвращаем id
        result_id := admin_id;
        error_message := 'Аутентификация успешна';
        RETURN;
    END IF;

EXCEPTION
    -- Ловим исключения (например, ошибки в запросе или другие ошибки выполнения)
    WHEN OTHERS THEN
        -- Если произошла ошибка, возвращаем 0
        result_id := 0;
        error_message := 'Произошла ошибка: ' || SQLERRM;
        RETURN;
END;
$$ LANGUAGE PLPGSQL;


select * from login_admin('menttare.h@gmail.com','admin@542');

-- функция для смены информации о профиле
CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id INTEGER,
    p_name VARCHAR,
    p_about_me VARCHAR,
    p_specialization INTEGER
) 
RETURNS BOOLEAN AS
$$
BEGIN
    -- Обновляем информацию о пользователе
    UPDATE Accounts
    SET 
        name = p_name,
        about_me = p_about_me,
        specialization = p_specialization
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



CREATE VIEW UserProfileInfo AS
SELECT
    a.id AS account_id,
	ip.id AS profile_image_id,
    ip.filename AS profile_image,
    a.email,
    a.phone,
    a.name,
    a.about_me,
	s.id AS specialization_id,
    s.name AS specialization,
    a.license_number,
    a.confirmation,
    a.created_at AS account_created_at
FROM
    Accounts a
LEFT JOIN
    ImagesProfile ip ON a.id_ImagesProfile = ip.id
LEFT JOIN
    Specializations s ON a.specialization = s.id;

select * from UserProfileInfo;


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





CREATE OR REPLACE FUNCTION get_user_profiles_info()
RETURNS SETOF UserProfileInfo AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM
        UserProfileInfo;
END;
$$ LANGUAGE plpgsql;


select * from get_user_profiles_info();


CREATE OR REPLACE FUNCTION update_account_confirmation(p_account_id INTEGER, p_new_confirmation BOOLEAN)
RETURNS BOOLEAN AS $$
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
$$ LANGUAGE plpgsql;


select update_account_confirmation(1, false); 


