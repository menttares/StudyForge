CREATE VIEW study_group_view AS
SELECT sg.id AS group_id,
       sg.enrollment,
       sg.date_start,
       sg.date_end,
       sg.price,
	   fs.id AS id_form_of_study,
       fs.Name AS form_of_study,
	   c.id AS id_city,
       c.Name AS city,
       sg.duration,
	   c1.id AS id_course_name,
       c1.name AS course_name,
       c1.description AS course_description,
	   s.id AS if_section,
       s.name AS section_name,
	   p.id AS id_profile,
	   p.name AS name_profile,
	   p.is_organization AS is_organization_profile,
	   get_accepted_applications_count(sg.id) AS accepted_applications_count,
       get_study_days(sg.id) AS study_days
FROM study_group sg
JOIN form_study fs ON sg.id_form_study = fs.id
LEFT JOIN city c ON sg.id_city = c.ID
JOIN courses c1 ON sg.id_course = c1.id
JOIN section s ON c1.id_section = s.id
JOIN profile p ON p.id = c1.id_profile;



-- поиск по нескольким критериям
CREATE OR REPLACE FUNCTION search_study_group_view(
    p_category_id INT DEFAULT NULL,
    p_form_of_study_id INT DEFAULT NULL,
    p_city_id INT DEFAULT NULL,
    p_search_string VARCHAR DEFAULT NULL,
    p_start_price NUMERIC DEFAULT NULL,
    p_end_price NUMERIC DEFAULT NULL,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_is_organization BOOLEAN DEFAULT NULL,
    p_has_vacancies BOOLEAN DEFAULT NULL,
	p_course_id INT DEFAULT NULL
) RETURNS TABLE (
    group_id INT,
    enrollment INT,
    date_start DATE,
    date_end DATE,
    price NUMERIC,
	id_form_study integer,
	name_form_study VARCHAR,
	id_course integer,
    course_name VARCHAR,
	course_description VARCHAR,
	id_section integer,
    section_name VARCHAR,
	id_profile integer,
    name_profile VARCHAR,
	id_city integer,
	city_name varchar,
    accepted_applications_count INT,
    study_days TEXT,
	is_organization bool,
	duration integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sg.id AS group_id, -- 0
        sg.enrollment, -- 1
        sg.date_start, -- 2
        sg.date_end, -- 3
        sg.price, -- 4
		fs.id AS id_form_study, -- 5
		fs.name AS name_form_study, -- 6
		c1.id AS id_course, --7
        c1.name AS course_name, -- 8
		c1.description as course_description, -- 9
		s.id AS id_section, --10
        s.name AS section_name, -- 11
		p.id AS id_profile, -- 12
        p.name AS name_profile, -- 13
		c.id AS id_city,
		c.name AS city_name,
        get_accepted_applications_count(sg.id) AS accepted_applications_count, -- 14
        get_study_days(sg.id) AS study_days, -- 15
		p.is_organization AS is_organization,
		sg.duration as duration
    FROM 
        study_group sg
    JOIN 
        courses c1 ON sg.id_course = c1.id
    JOIN 
        section s ON c1.id_section = s.id
    JOIN 
        profile p ON p.id = c1.id_profile
	JOIN
		form_study fs ON fs.id = sg.id_form_study
	JOIN
		city c ON c.id = sg.id_city
    WHERE
        (p_category_id IS NULL OR c1.id_section = p_category_id) AND
        (p_form_of_study_id IS NULL OR sg.id_form_study = p_form_of_study_id) AND
        (p_city_id IS NULL OR sg.id_city = p_city_id) AND
        (p_search_string IS NULL OR (c1.name ILIKE '%' || p_search_string || '%' OR c1.description ILIKE '%' || p_search_string || '%' OR p.name ILIKE '%' || p_search_string || '%')) AND
        (p_start_price IS NULL OR sg.price >= p_start_price) AND
        (p_end_price IS NULL OR sg.price <= p_end_price) AND
        (p_start_date IS NULL OR sg.date_start >= p_start_date) AND
        (p_end_date IS NULL OR sg.date_end <= p_end_date) AND
        (p_is_organization IS NULL OR p.is_organization = p_is_organization) AND
        (p_has_vacancies IS NULL OR sg.enrollment > get_accepted_applications_count(sg.id)) AND
		(p_course_id IS NULL OR sg.id_course = p_course_id);
END;
$$ LANGUAGE plpgsql;