
-- форма обучения
CREATE TABLE FormsTraining (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

-- города РБ и другие
CREATE TABLE Cities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

select * from studygroups;

-- учебная группа
CREATE TABLE studygroups (
  id serial PRIMARY KEY,
  -- набор
  enrollment integer not NULL check (enrollment > 0 and enrollment < 300),
  -- дата начала набора
  date_start date not NULL DEFAULT CURRENT_DATE,
  -- дата окончания набора (необязательно)
  date_end date NULL CHECK (
    date_end >= date_start
    OR date_end IS NULL
  ),
	-- цена
  price numeric(10, 2) null check (
    price > 0
    and price < 10000000
  ) DEFAULT 0,
	-- форма обучения
  id_FormsTraining integer REFERENCES FormsTraining(id) ON DELETE SET NULL,
	-- город 
  id_city integer REFERENCES Cities(id) ON DELETE SET NULL,
  -- длительность в часах
  duration integer NULL check (duration > 0 and duration < 5000),

  id_course INTEGER REFERENCES courses(id) ON DELETE CASCADE,
	
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- учебная группа
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

SELECT create_study_group(
    p_enrollment := 10, 
    p_date_start := '2024-06-01', 
    p_date_end := '2024-08-31', 
    p_price := 1000.00, 
    p_id_FormsTraining := 1, 
    p_id_city := 1, 
    p_duration := 120, 
    p_id_course := 2
) AS new_group_id;




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



CREATE OR REPLACE VIEW StudyGroupsView AS
SELECT
    sg.id,
    sg.enrollment,
    sg.date_start,
    sg.date_end,
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

select * from StudyGroupsView;






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
    sg.date_end AS group_date_end,
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


select * from CourseAndGroupView;




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


-- измененный фильтр
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








-- Функция для вывода всех данных из таблицы FormsTraining
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



SELECT * FROM get_all_forms_training();
SELECT * FROM get_all_cities();


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

select * from get_study_groups_by_course_id(34);
select * from get_study_groups_by_course_id(34);

CREATE OR REPLACE FUNCTION get_study_group_by_id(p_group_id INTEGER)
RETURNS SETOF StudyGroupsView AS $$
BEGIN
    RETURN QUERY SELECT *
                 FROM StudyGroupsView
                 WHERE id = p_group_id;
END;
$$ LANGUAGE PLPGSQL;

select * from get_study_group_by_id(4);






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

select * from delete_study_group_by_id(5);



