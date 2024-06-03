CREATE VIEW course_view AS
SELECT c.id AS course_id,
    c.name AS course_name,
    c.description AS course_description,
    c.created_at AS course_created_at,
    c.course_closed AS course_closed,
    s.id AS section_id,
    s.name AS section_name,
    p.id AS profile_id,
    p.name AS profile_name,
    p.is_organization AS profile_is_organization
FROM courses c
    JOIN section s ON c.id_section = s.id
    JOIN profile p ON c.id_profile = p.id;


    
--  фукнция получения курса по id по представлению
CREATE OR REPLACE FUNCTION get_course_by_id(p_course_id INT) RETURNS TABLE (
        course_id INT,
        course_name VARCHAR(60),
        course_description VARCHAR(500),
        course_created_at TIMESTAMP,
        course_closed BOOLEAN,
        section_id INT,
        section_name VARCHAR(255),
        profile_id INT,
        profile_name VARCHAR(255),
        about_me TEXT,
        specialization VARCHAR(255),
        confirmation BOOLEAN,
        profile_is_organization BOOLEAN
    ) AS $$ BEGIN RETURN QUERY
SELECT c.id AS course_id,
    c.name AS course_name,
    c.description AS course_description,
    c.created_at AS course_created_at,
    c.course_closed AS course_closed,
    s.id AS section_id,
    s.name AS section_name,
    p.id AS profile_id,
    p.name AS profile_name,
    p.about_me AS about_me,
    p.specialization AS specialization,
    p.confirmation AS confirmation,
    p.is_organization AS profile_is_organization
FROM courses c
    JOIN section s ON c.id_section = s.id
    JOIN profile p ON c.id_profile = p.id
WHERE c.id = p_course_id;
END;
$$ LANGUAGE plpgsql;