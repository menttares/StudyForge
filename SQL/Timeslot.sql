CREATE TABLE Days (
  id SERIAL PRIMARY KEY,
  name VARCHAR(30) UNIQUE NOT NULL CHECK (name IN ('ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'))
);

INSERT INTO Days (name) VALUES 
('ПН'),
('ВТ'),
('СР'),
('ЧТ'),
('ПТ'),
('СБ'),
('ВС');


create table timeslot_StudyGroups (
  id SERIAL PRIMARY KEY,
  id_day INTEGER REFERENCES Days(id) ON DELETE CASCADE,
  id_studyGroup INTEGER REFERENCES StudyGroups(id) ON DELETE CASCADE
);


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


CREATE OR REPLACE FUNCTION GetAllDays()
RETURNS SETOF Days
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Days;
END;
$$ LANGUAGE plpgsql;

select * from GetAllDays();



