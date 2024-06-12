-- Профиль


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






