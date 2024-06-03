-- таблица временных токенов для восстановления пароля
CREATE TABLE PasswordResetTokens (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES Accounts(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 day', -- Автоматический срок действия токена на 1 день
    used BOOLEAN DEFAULT FALSE -- Поле, указывающее, был ли токен использован для сброса пароля
);


-- функция возвращения токена
CREATE OR REPLACE FUNCTION generate_password_reset_token(p_account_id INTEGER)
RETURNS VARCHAR(255) AS
$$
DECLARE
    reset_token VARCHAR(255);
BEGIN
    -- Генерируем уникальный токен
    reset_token := md5(random()::text || clock_timestamp()::text || p_account_id::text);

    -- Вставляем токен в таблицу PasswordResetTokens
    INSERT INTO PasswordResetTokens (account_id, token)
    VALUES (p_account_id, reset_token);

    -- Возвращаем сгенерированный токен
    RETURN reset_token;
END;
$$
LANGUAGE PLPGSQL;

select * from generate_password_reset_token(4);


-- функция удаления старых и использованных токенов
CREATE OR REPLACE FUNCTION delete_expired_tokens()
RETURNS VOID AS
$$
BEGIN
    -- Удаляем токены, у которых срок действия истек и которые не были использованы
    DELETE FROM PasswordResetTokens WHERE expires_at <= CURRENT_TIMESTAMP AND used = FALSE;
END;
$$
LANGUAGE PLPGSQL;




