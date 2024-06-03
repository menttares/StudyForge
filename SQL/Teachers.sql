CREATE TABLE TeachersAvatar (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);


-- преподаватель
CREATE TABLE Teacher (
  id SERIAL PRIMARY KEY,
  id_Course INTEGER REFERENCES Courses(id) ON DELETE CASCADE,
	-- необязательно
  id_Avatar INTEGER REFERENCES TeachersAvatar(id) ON DELETE SET NULL,
  firstName VARCHAR(255) NOT NULL,
  lastName VARCHAR(255) NOT NULL,
  aboutMe VARCHAR(500) NULL,
  skills VARCHAR(255) NULL,
  specialization INTEGER  REFERENCES Specializations(id) ON DELETE SET NULL
);