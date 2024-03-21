
-- Создание таблицы "изображений профиля"
CREATE TABLE ImagesProfile (
	-- ID ключ
    id SERIAL PRIMARY KEY,
	-- Имя файла
    filename TEXT not null
);

INSERT INTO ImagesProfile(filename) values (
	'DEFAULT'
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
  

