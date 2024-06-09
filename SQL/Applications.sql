-- статус заявки 
CREATE TABLE StatusApplications (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL CHECK (name IN ('принято', 'отклонено', 'ожидание'))
);

INSERT INTO StatusApplications (name) VALUES 
    ('принято'),
    ('отклонено'),
    ('ожидание');


select * from StatusApplications;
select * from applications;

create table applications(
  id SERIAL PRIMARY KEY,
  id_StudyGroup INTEGER REFERENCES StudyGroups(id) ON DELETE CASCADE,
  firstName VARCHAR(60) NOT NULL check (
    LENGTH(firstName) >= 3
    and LENGTH(firstName) < 60
  ),
  lastName VARCHAR(60) NOT NULL check (
    LENGTH(lastName) >= 3
    and LENGTH(lastName) < 60
  ),
  surname VARCHAR(60) NULL check (
    LENGTH(lastName) < 60
  ),
  phone VARCHAR(60) NOT NULL check (
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
	
  email VARCHAR(100) NOT NULL CHECK (email LIKE '%@%'),
	
  id_StatusApplications INTEGER REFERENCES StatusApplications(id),
  
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE VIEW ApplicationsPerCourse AS
SELECT
    c.id AS course_id,
    c.name AS course_name,
    COUNT(a.id) AS application_count,
	c.id_Account AS creator_id
FROM
    Courses c
LEFT JOIN
    StudyGroups sg ON c.id = sg.id_Course
LEFT JOIN
    Applications a ON sg.id = a.id_StudyGroup
GROUP BY
    c.id,
    c.name;


CREATE OR REPLACE FUNCTION GetCourseApplicationsStatisticsByCreatorId(p_creator_id INTEGER)
RETURNS SETOF ApplicationsPerCourse AS
$$
BEGIN
    RETURN QUERY
    SELECT *
    FROM ApplicationsPerCourse
    WHERE creator_id = p_creator_id;
END;
$$
LANGUAGE plpgsql;


select * from GetCourseApplicationsStatisticsByCreatorId(1);


CREATE OR REPLACE FUNCTION get_applications_by_creator(creator_id INT)
RETURNS SETOF CourseApplicationsStatisticsView AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE id_Account = creator_id) THEN
        RAISE NOTICE 'No creator with id %', creator_id;
        RETURN;
    END IF;
    
    RETURN QUERY
    SELECT asv.*
    FROM 
        CourseApplicationsStatisticsView asv
    JOIN 
        Courses c ON asv.course_id = c.id
    WHERE 
        c.id_Account = creator_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_applications_by_creator(1);



ALTER TABLE applications ADD COLUMN submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION create_application(
	p_id_StudyGroup INTEGER,
    p_firstName VARCHAR(60),
    p_lastName VARCHAR(60),
    p_surname VARCHAR(60),
    p_phone VARCHAR(15),
    p_birthday DATE,
	p_email VARCHAR(255)
) 
RETURNS INTEGER AS
$$
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
EXCEPTION
    WHEN others THEN
        RETURN 0;
END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION update_application_status(
    p_application_id INTEGER,
    p_new_status_id INTEGER
) 
RETURNS BOOLEAN AS
$$
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
$$
LANGUAGE PLPGSQL;




CREATE OR REPLACE FUNCTION count_accepted_applications(p_group_id INTEGER)
RETURNS INTEGER AS
$$
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
$$
LANGUAGE PLPGSQL;



CREATE VIEW v_applications_details AS
SELECT
    a.id AS application_id,
    a.firstName,
    a.lastName,
    a.surname,
    a.phone,
    a.birthday,
    a.email,
    a.id_StatusApplications,
    a.submission_date,
    sg.id AS studygroup_id,
    sg.enrollment,
    sg.date_start,
    sg.date_end,
    sg.price,
    sg.duration,
    ft.name AS form_training_name,
    c.name AS city_name,
	co.id AS course_id,
	co.name
FROM
    applications a
JOIN
    studygroups sg ON a.id_StudyGroup = sg.id
LEFT JOIN
    FormsTraining ft ON sg.id_FormsTraining = ft.id
LEFT JOIN
    Cities c ON sg.id_city = c.id
JOIN
    courses co ON sg.id_course = co.id;

select * from v_applications_details;



CREATE OR REPLACE FUNCTION get_applications(
    p_id_course INTEGER,
    p_id_status INTEGER DEFAULT NULL
)
RETURNS SETOF v_applications_details AS $$
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
$$ LANGUAGE plpgsql;


select * from get_applications(28, 3);


select * from applications;
delete 

