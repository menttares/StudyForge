using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;
using System.Collections.Generic;
using StudyForge.Models;

namespace StudyForge.Services;

public enum ResultPostgresStatus
{
    Ok,
    PostgresError,
    ValidDataError,
    Exception
}



public record class ResultPostgresData(ResultPostgresStatus Status, int Result, string? MessageError);

public record class ResultPostgresData<T>(ResultPostgresStatus Status, T Result, string? MessageError);

public class PostgresDataService
{
    private readonly string _connectionString;

    public PostgresDataService(string connectionString)
    {
        _connectionString = connectionString;
    }


    /// <summary>
    /// Проверяет пользователя на почту и пароль
    /// </summary>
    /// <param name="email">Email</param>
    /// <param name="password">Пароль</param>
    /// <returns>Целочисленное значение: 1 в случае успешной проверки, -1 если пользователь с таким email не существует, -2 в случае ошибки пароля, 0 в случае внутренее ошибки postgres</returns>
    public ResultPostgresData login_user(string email, string password)
    {

        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT login_user(@p_email, @p_password)", connection))
                {
                    command.Parameters.AddWithValue("p_email", email);
                    command.Parameters.AddWithValue("p_password", password);
                    var result = command.ExecuteScalar();
                    int id = Convert.ToInt32(result);

                    switch (id)
                    {
                        case > 0:
                            return new ResultPostgresData(ResultPostgresStatus.Ok, id, string.Empty);
                        case -1:
                            return new ResultPostgresData(ResultPostgresStatus.ValidDataError, id, "Почты не существует");
                        case -2:
                            return new ResultPostgresData(ResultPostgresStatus.ValidDataError, id, "Пароль не верный");
                        case 0:
                            return new ResultPostgresData(ResultPostgresStatus.PostgresError, id, "внутреняя ошибка postgres");
                        default:
                            return new ResultPostgresData(ResultPostgresStatus.PostgresError, id, "Неизвестаная ошибка postgres");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return new ResultPostgresData(ResultPostgresStatus.Exception, 0, ex.Message);
        }
    }

    /// <summary>
    /// Регистрирует новый профиль в базе данных.
    /// </summary>
    /// <param name="name">Имя аккаунта</param>
    /// <param name="licenseNumber">Номер лицензии</param>
    /// <param name="email">Email</param>
    /// <param name="password">Пароль</param>
    /// <param name="isOrganization">Флаг, указывающий является ли аккаунт организацией</param>
    /// <param name="phone">Телефон (Только белорусский)</param>
    /// <returns>Целочисленное значение: 1 в случае успешной регистрации, -1 если пользователь с таким email уже существует, 0 в случае ошибки.</returns>
    public ResultPostgresData register_profile(
        string name,
        string licenseNumber,
        string email,
        string password,
        bool isOrganization,
        string phone
    )
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT register_profile(@p_name, @p_license_number, @p_email, @p_password, @p_is_organization, @p_phone)", connection))
                {
                    command.Parameters.AddWithValue("p_name", name);
                    command.Parameters.AddWithValue("p_license_number", licenseNumber);
                    command.Parameters.AddWithValue("p_email", email);
                    command.Parameters.AddWithValue("p_password", password);
                    command.Parameters.AddWithValue("p_is_organization", isOrganization);
                    command.Parameters.AddWithValue("p_phone", phone);
                    var result = command.ExecuteScalar();
                    int id = Convert.ToInt32(result);

                    switch (id)
                    {
                        case > 0:
                            return new ResultPostgresData(ResultPostgresStatus.Ok, id, string.Empty);
                        case -1:
                            return new ResultPostgresData(ResultPostgresStatus.ValidDataError, id, "Почты не существует");
                        case -2:
                            return new ResultPostgresData(ResultPostgresStatus.ValidDataError, id, "Пароль не верный");
                        case 0:
                            return new ResultPostgresData(ResultPostgresStatus.PostgresError, id, "внутреняя ошибка postgres");
                        default:
                            return new ResultPostgresData(ResultPostgresStatus.PostgresError, id, "Неизвестаная ошибка postgres");
                    }

                }
            }
        }
        catch (Exception ex)
        {
            return new ResultPostgresData(ResultPostgresStatus.Exception, 0, ex.Message);
        }
    }


    public ResultPostgresData<List<StudyGroupResultModel>> search_study_group_view(
     int? p_category_id = null,
     int? p_form_of_study_id = null,
     int? p_city_id = null,
     string? p_search_string = null,
     decimal? p_start_price = null,
     decimal? p_end_price = null,
     DateTime? p_start_date = null,
     DateTime? p_end_date = null,
     bool? p_is_organization = null,
     bool? p_has_vacancies = null,
     int? p_course_id = null
 )
    {
        try
        {
            var resultList = new List<StudyGroupResultModel>();

            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT * FROM search_study_group_view(" +
                                                       "@p_category_id, " +
                                                       "@p_form_of_study_id, " +
                                                       "@p_city_id, " +
                                                       "@p_search_string, " +
                                                       "@p_start_price, " +
                                                       "@p_end_price, " +
                                                       "@p_start_date, " +
                                                       "@p_end_date, " +
                                                       "@p_is_organization, " +
                                                       "@p_has_vacancies, " +
                                                       "@p_course_id)", connection))
                {
                    // Добавляем параметры запроса
                    command.Parameters.AddWithValue("p_category_id", NpgsqlDbType.Integer, (object)p_category_id ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_form_of_study_id", NpgsqlDbType.Integer, (object)p_form_of_study_id ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_city_id", NpgsqlDbType.Integer, (object)p_city_id ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_search_string", NpgsqlDbType.Varchar, (object)p_search_string ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_start_price", NpgsqlDbType.Numeric, (object)p_start_price ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_end_price", NpgsqlDbType.Numeric, (object)p_end_price ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_start_date", NpgsqlDbType.Date, (object)p_start_date ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_end_date", NpgsqlDbType.Date, (object)p_end_date ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_is_organization", NpgsqlDbType.Boolean, (object)p_is_organization ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_has_vacancies", NpgsqlDbType.Boolean, (object)p_has_vacancies ?? DBNull.Value);
                    command.Parameters.AddWithValue("p_course_id", NpgsqlDbType.Integer, (object)p_course_id ?? DBNull.Value);
                    using (var reader = command.ExecuteReader())
                    {
                        // Читаем данные из результата запроса и добавляем их в список результатов
                        while (reader.Read())
                        {
                            var result = new StudyGroupResultModel
                            {
                                GroupId = reader.GetInt32(0),
                                Enrollment = reader.GetInt32(1),
                                DateStart = reader.GetDateTime(2),
                                DateEnd = reader.GetDateTime(3),
                                Price = reader.GetDecimal(4),
                                FormOfStudyId = reader.GetInt32(5),
                                FormOfStudyName = reader.GetString(6),
                                CourseId = reader.GetInt32(7),
                                CourseName = reader.GetString(8),
                                CourseDescription = reader.GetString(9),
                                SectionId = reader.GetInt32(10),
                                SectionName = reader.GetString(11),
                                ProfileId = reader.GetInt32(12),
                                ProfileName = reader.GetString(13),
                                CityId = reader.GetInt32(14),
                                CityName = reader.GetString(15),
                                AcceptedApplicationsCount = reader.GetInt32(16),
                                StudyDays = reader.GetString(17),
                                IsOrganization = reader.GetBoolean(18),
                                Duration = reader.GetInt32(19)

                            };

                            resultList.Add(result);
                        }
                    }
                }
            }

            return new ResultPostgresData<List<StudyGroupResultModel>>(ResultPostgresStatus.Ok, resultList, null);
        }
        catch (Exception ex)
        {
            return new ResultPostgresData<List<StudyGroupResultModel>>(ResultPostgresStatus.Exception, null, ex.Message);
        }
    }




    public ResultPostgresData<CourseModel> GetCourseById(int courseId)
    {
        CourseModel course = new();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("select * from get_course_by_id(@p_course_id)", connection))
            {
                command.Parameters.AddWithValue("p_course_id", courseId);
                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {

                        course.CourseId = reader.GetInt32(0);
                        course.CourseName = reader.IsDBNull(1) ? null : reader.GetString(1);
                        course.CourseDescription = reader.IsDBNull(2) ? null : reader.GetString(2);
                        course.CourseCreatedAt = reader.GetDateTime(3);
                        course.CourseClosed = reader.GetBoolean(4);
                        course.SectionId = reader.GetInt32(5);
                        course.SectionName = reader.GetString(6);
                        course.ProfileId = reader.GetInt32(7);
                        course.ProfileName = reader.GetString(8);
                        course.ProfileAboutMe = reader.IsDBNull(9) ? null : reader.GetString(9);
                        course.ProfileSpecialization = reader.IsDBNull(10) ? null : reader.GetString(10);
                        course.ProfileConfirmation = reader.IsDBNull(11) ? null : reader.GetBoolean(11);
                        course.ProfileIsOrganization = reader.GetBoolean(12);
                    }
                }
            }
        }

        return new ResultPostgresData<CourseModel>(ResultPostgresStatus.Ok, course, null);
    }


    public ResultPostgresData<List<SectionModel>> GetAllSections()
    {
        List<SectionModel> sections = new List<SectionModel>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("select * from GetAllSections()", connection))
            {


                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        SectionModel section = new SectionModel();
                        section.id = reader.GetInt32(0);
                        section.id_category = reader.GetInt32(1);
                        section.name = reader.GetString(2);
                        sections.Add(section);
                    }
                }
            }
        }

        return new ResultPostgresData<List<SectionModel>>(ResultPostgresStatus.Ok, sections, null);
    }


    public ResultPostgresData<List<TeacherModel>> GetTeachersByCourseId(int courseId)
    {
        List<TeacherModel> teachers = new List<TeacherModel>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM GetTeachersByCourseId(@courseId)", connection))
            {
                command.Parameters.AddWithValue("courseId", courseId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        TeacherModel teacher = new TeacherModel();
                        teacher.TeacherId = reader.GetInt32(0);
                        teacher.FirstName = reader.GetString(1);
                        teacher.AboutMe = reader.GetString(2);
                        teacher.Skills = reader.GetString(3);
                        teacher.Specialization = reader.GetString(4);
                        teachers.Add(teacher);
                    }
                }
            }
        }

        return new ResultPostgresData<List<TeacherModel>>(ResultPostgresStatus.Ok, teachers, "");
    }


    public ResultPostgresData<List<ProgramModelCourse>> GetProgramsByCourseId(int courseId)
    {
        List<ProgramModelCourse> programs = new List<ProgramModelCourse>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM GetProgramsByCourseId(@courseId)", connection))
            {
                command.Parameters.AddWithValue("courseId", courseId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ProgramModelCourse program = new ProgramModelCourse();
                        program.ProgramId = reader.GetInt32(0);
                        program.ProgramName = reader.GetString(1);
                        program.ProgramDescription = reader.GetString(2);
                        programs.Add(program);
                    }
                }
            }
        }

        return new ResultPostgresData<List<ProgramModelCourse>>(ResultPostgresStatus.Ok, programs, string.Empty);
    }


    public ResultPostgresData<int> CreateApplication(int studyGroupId, string firstName, string phone, DateTime birthday)
    {
        int newApplicationId = 0;

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("select * from create_application(@p_study_group_id, @p_first_name, @p_phone, @p_birthday)", connection))
            {
                command.Parameters.AddWithValue("p_study_group_id", studyGroupId);
                command.Parameters.AddWithValue("p_first_name", firstName);
                command.Parameters.AddWithValue("p_phone", phone);
                command.Parameters.AddWithValue("p_birthday", NpgsqlDbType.Timestamp, birthday);

                // Используем ExecuteScalar() для получения единственного значения
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        newApplicationId = reader.GetInt32(0);
                    }
                }
            }
        }

        return new ResultPostgresData<int>(ResultPostgresStatus.Ok, newApplicationId, null);
    }


    public ResultPostgresData<ProfileModel> GetProfileData(int profileId)
    {
        ProfileModel profile = null;

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("SELECT * FROM get_profile_data(@profileId)", connection))
            {
                command.Parameters.AddWithValue("profileId", profileId);

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        profile = new ProfileModel
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("id")),
                            Email = reader.GetString(reader.GetOrdinal("email")),
                            Name = reader.GetString(reader.GetOrdinal("name")),
                            LicenseNumber = reader.GetString(reader.GetOrdinal("license_number")),
                            IsOrganization = reader.GetBoolean(reader.GetOrdinal("is_organization")),
                            Phone = reader.GetString(reader.GetOrdinal("phone")),
                            AboutMe = reader.IsDBNull(reader.GetOrdinal("about_me")) ? null : reader.GetString(reader.GetOrdinal("about_me")),
                            Specialization = reader.IsDBNull(reader.GetOrdinal("specialization")) ? null : reader.GetString(reader.GetOrdinal("specialization")),
                            Confirmation = reader.IsDBNull(reader.GetOrdinal("confirmation")) ? false : reader.GetBoolean(reader.GetOrdinal("confirmation")),
                            CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at"))
                            // Добавьте остальные свойства профиля, если необходимо
                        };
                    }
                }
            }
        }

        return new(ResultPostgresStatus.Ok, profile, null);
    }


    public ResultPostgresData<List<CourseModel>> GetProfileCourses(int profileId)
    {
        List<CourseModel> courses = new List<CourseModel>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("SELECT * FROM get_profile_courses(@profileId)", connection))
            {
                command.Parameters.AddWithValue("profileId", profileId);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new CourseModel
                        {
                            CourseId = reader.GetInt32(reader.GetOrdinal("course_id")),
                            CourseName = reader.GetString(reader.GetOrdinal("course_name")),
                            CourseDescription = reader.GetString(reader.GetOrdinal("course_description"))
                        });
                    }
                }
            }
        }

        return new ResultPostgresData<List<CourseModel>>(ResultPostgresStatus.Ok, courses, null);
    }


    public ResultPostgresData<List<ApplicationData>> GetApplicationsByStatus(int statusId, int profile_id)
    {
        List<ApplicationData> applications = new List<ApplicationData>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("SELECT * FROM get_applications_by_status(@statusId, @p_profile_id)", connection))
            {

                command.Parameters.AddWithValue("statusId", statusId);
                command.Parameters.AddWithValue("p_profile_id", profile_id);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        applications.Add(new ApplicationData
                        {
                            ApplicationId = reader.GetInt32(reader.GetOrdinal("application_id")),
                            StudyGroupId = reader.GetInt32(reader.GetOrdinal("id_study_group")),
                            Enrollment = reader.GetInt32(reader.GetOrdinal("study_group_enrollment")),
                            DateStart = reader.GetDateTime(reader.GetOrdinal("study_group_date_start")),
                            DateEnd = reader.IsDBNull(reader.GetOrdinal("study_group_date_end")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("study_group_date_end")),
                            Price = reader.IsDBNull(reader.GetOrdinal("study_group_price")) ? (decimal?)null : reader.GetDecimal(reader.GetOrdinal("study_group_price")),
                            FormStudyId = reader.GetInt32(reader.GetOrdinal("study_group_id_form_study")),
                            CityId = reader.IsDBNull(reader.GetOrdinal("study_group_id_city")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("study_group_id_city")),
                            Duration = reader.IsDBNull(reader.GetOrdinal("study_group_duration")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("study_group_duration")),
                            CourseId = reader.IsDBNull(reader.GetOrdinal("study_group_id_course")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("study_group_id_course")),
                            FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                            Phone = reader.GetString(reader.GetOrdinal("phone")),
                            Birthday = reader.GetDateTime(reader.GetOrdinal("birthday")),
                            StatusApplicationsId = reader.GetInt32(reader.GetOrdinal("id_status_applications"))
                        });
                    }
                }
            }
        }

        return new ResultPostgresData<List<ApplicationData>>(ResultPostgresStatus.Ok, applications, null);
    }


    public void ChangeApplicationStatus(int newStatusId, int applicationId)
    {
        using (var conn = new NpgsqlConnection(_connectionString))
        {
            conn.Open();

            using (var cmd = new NpgsqlCommand())
            {
                cmd.Connection = conn;

                // Здесь используем текстовый SQL запрос
                cmd.CommandText = "UPDATE applications SET id_status_applications = @new_status_id WHERE id = @application_id";

                // Добавляем параметры
                cmd.Parameters.AddWithValue("@new_status_id", newStatusId);
                cmd.Parameters.AddWithValue("@application_id", applicationId);

                cmd.ExecuteNonQuery();
            }
        }
    }
}