using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;
using System.Collections.Generic;
using StudyForge.Models;
using Newtonsoft.Json;
using Microsoft.IdentityModel.Tokens;

namespace StudyForge.Services;

public enum ResultPostgresStatus
{
    Ok,
    PostgresError,
    ValidDataError,
    Exception
}

public record class ResultPostgresData(ResultPostgresStatus Status, int Result, string? Message);

public record class ResultPostgresData<T>(ResultPostgresStatus Status, T Result, string? Message);


public class PostgresDataService
{
    private readonly string _connectionString;

    public PostgresDataService(string connectionString)
    {
        _connectionString = connectionString;
    }


    public ResultPostgresData login_user(string email, string password)
    {

        // try
        // {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("select * from login_user(@p_email , @p_password);", connection))
            {

                command.Parameters.AddWithValue("p_email", email);
                command.Parameters.AddWithValue("p_password", password);


                command.ExecuteNonQuery();

                int resultId = Convert.ToInt32(command.ExecuteScalar());

                switch (resultId)
                {
                    case > 0:
                        return new ResultPostgresData(ResultPostgresStatus.Ok, resultId, "");
                    default:
                        return new ResultPostgresData(ResultPostgresStatus.ValidDataError, resultId, "Внутренния ошибка БД");
                }
            }
        }
        // }
        // catch (Exception ex)
        // {
        //     return new ResultPostgresData(ResultPostgresStatus.Exception, 0, ex.Message);
        // }
    }


    public ResultPostgresData register_profile(
        string name,
        string licenseNumber,
        string email,
        string password,
        bool isOrganization,
        string phone
    )
    {
        // try
        // {
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


                command.ExecuteNonQuery();

                int resultId = Convert.ToInt32(command.ExecuteScalar());

                switch (resultId)
                {
                    case > 0:
                        return new ResultPostgresData(ResultPostgresStatus.Ok, resultId, "");
                    default:
                        return new ResultPostgresData(ResultPostgresStatus.ValidDataError, resultId, "Внутренния ошибка БД");
                }

            }
        }
        // }
        // catch (Exception ex)
        // {
        //     return new ResultPostgresData(ResultPostgresStatus.Exception, 0, ex.Message);
        // }
    }


    public List<CategoryWithSubsections> GetCategoriesWithSubsections()
    {
        var categoriesWithSubsections = new List<CategoryWithSubsections>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT * FROM get_categories_with_subsections()", connection))
            {
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string categoryName = reader.GetString(0);
                        string subsectionsJson = reader.GetString(1);

                        var subsections = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Subsection>>(subsectionsJson);

                        var category = new CategoryWithSubsections
                        {
                            CategoryName = categoryName,
                            Subsections = subsections
                        };

                        categoriesWithSubsections.Add(category);
                    }
                }
            }
        }

        return categoriesWithSubsections;
    }

    public List<CourseAndGroupView> FilterCoursesAndGroups(int? sectionId = null, DateTime? startDate = null, DateTime? endDate = null, decimal? minPrice = null, decimal? maxPrice = null,
         int? durationHours = null, bool organizationOnly = false, bool freeOnly = false, string? searchQuery = null)
    {
        List<CourseAndGroupView> coursesAndGroups = new List<CourseAndGroupView>();


        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM filter_courses_and_groups(@p_section_id, @p_start_date, @p_end_date, @p_min_price, @p_max_price, @p_duration_hours, @p_organization_only, @p_free_only, @p_search_query)", connection))
            {
                // Добавление параметров
                command.Parameters.AddWithValue("p_section_id", NpgsqlDbType.Integer, (object)sectionId ?? DBNull.Value);
                command.Parameters.AddWithValue("p_start_date", NpgsqlDbType.Date, (object)startDate ?? DBNull.Value);
                command.Parameters.AddWithValue("p_end_date", NpgsqlDbType.Date, (object)endDate ?? DBNull.Value);
                command.Parameters.AddWithValue("p_min_price", NpgsqlDbType.Numeric, (object)minPrice ?? DBNull.Value);
                command.Parameters.AddWithValue("p_max_price", NpgsqlDbType.Numeric, (object)maxPrice ?? DBNull.Value);
                command.Parameters.AddWithValue("p_duration_hours", NpgsqlDbType.Integer, (object)durationHours ?? DBNull.Value);
                command.Parameters.AddWithValue("p_organization_only", NpgsqlDbType.Boolean, (object)organizationOnly ?? DBNull.Value);
                command.Parameters.AddWithValue("p_free_only", NpgsqlDbType.Boolean, (object)freeOnly ?? DBNull.Value);
                command.Parameters.AddWithValue("p_search_query", NpgsqlDbType.Varchar, (object)searchQuery ?? DBNull.Value);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        CourseAndGroupView courseAndGroup = new CourseAndGroupView();

                        courseAndGroup.CourseId = reader.GetInt32(0);
                        courseAndGroup.CourseName = reader.GetString(1);
                        courseAndGroup.CourseDescription = reader.GetString(2);
                        courseAndGroup.SectionId = reader.GetInt32(3);
                        courseAndGroup.SectionName = reader.GetString(4);
                        courseAndGroup.CreatorName = reader.GetString(5);
                        courseAndGroup.CreatorEmail = reader.GetString(6);
                        courseAndGroup.CreatorPhone = reader.GetString(7);
                        courseAndGroup.CreatorIsOrganization = reader.GetBoolean(8);
                        courseAndGroup.GroupId = reader.GetInt32(9);
                        courseAndGroup.GroupEnrollment = reader.GetInt32(10);
                        courseAndGroup.GroupDateStart = reader.GetDateTime(11);
                        courseAndGroup.GroupDateEnd = reader.IsDBNull(12) ? null : reader.GetDateTime(12);
                        courseAndGroup.GroupPrice = reader.GetDecimal(13);
                        courseAndGroup.GroupDuration = reader.GetInt32(14);
                        courseAndGroup.AcceptedApplicationsCount = reader.GetInt32(15);
                        courseAndGroup.ScheduleDays = reader.GetString(16);
                        courseAndGroup.CourseClosed = reader.GetBoolean(17);
                        courseAndGroup.FormTrainingName = reader.IsDBNull(18) ? null : reader.GetString(18);
                        courseAndGroup.CityName = reader.IsDBNull(19) ? null : reader.GetString(19);

                        coursesAndGroups.Add(courseAndGroup);
                    }
                }
            }
        }


        return coursesAndGroups;
    }




    public UserProfileInfo GetUserProfileInfo(int profileId)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("select * from get_user_profile_info(@p_profile_id);", connection))
            {
                command.Parameters.AddWithValue("p_profile_id", profileId);

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Присваиваем значения, только если они не являются DBNull
                        var userProfileInfo = new UserProfileInfo();
                        userProfileInfo.AccountId = reader["account_id"] != DBNull.Value ? Convert.ToInt32(reader["account_id"]) : 0;
                        userProfileInfo.ProfileImageId = reader["profile_image_id"] != DBNull.Value ? Convert.ToInt32(reader["profile_image_id"]) : 0;
                        userProfileInfo.ProfileImage = reader["profile_image"] != DBNull.Value ? reader["profile_image"].ToString() : string.Empty;
                        userProfileInfo.Email = reader["email"] != DBNull.Value ? reader["email"].ToString() : string.Empty;
                        userProfileInfo.Phone = reader["phone"] != DBNull.Value ? reader["phone"].ToString() : string.Empty;
                        userProfileInfo.Name = reader["name"] != DBNull.Value ? reader["name"].ToString() : string.Empty;
                        userProfileInfo.AboutMe = reader["about_me"] != DBNull.Value ? reader["about_me"].ToString() : string.Empty;
                        userProfileInfo.SpecializationId = reader["specialization_id"] != DBNull.Value ? Convert.ToInt32(reader["specialization_id"]) : 0;
                        userProfileInfo.Specialization = reader["specialization"] != DBNull.Value ? reader["specialization"].ToString() : string.Empty;
                        userProfileInfo.LicenseNumber = reader["license_number"] != DBNull.Value ? reader["license_number"].ToString() : string.Empty;
                        userProfileInfo.Confirmation = reader["confirmation"] != DBNull.Value ? Convert.ToBoolean(reader["confirmation"]) : false;
                        userProfileInfo.AccountCreatedAt = reader["account_created_at"] != DBNull.Value ? Convert.ToDateTime(reader["account_created_at"]) : DateTime.MinValue;

                        return userProfileInfo;
                    }
                }
            }
        }

        return null;
    }


    public List<Specialization> GetAllSpecializations()
    {
        List<Specialization> specializations = new List<Specialization>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT * FROM get_all_specializations()", connection))
            {
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        specializations.Add(new Specialization
                        {
                            Id = Convert.ToInt32(reader["specialization_id"]),
                            Name = reader["specialization_name"].ToString()
                        });
                    }
                }
            }
        }

        return specializations;
    }

    public bool UpdateUserProfile(int userId, string name, string aboutMe, int? specializationId, string email, string phone)
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT update_user_profile(@p_user_id, @p_name, @p_about_me, @p_specialization, @p_email, @p_phone)", connection))
                {
                    command.Parameters.AddWithValue("p_user_id", userId);
                    command.Parameters.AddWithValue("p_name", name);
                    command.Parameters.AddWithValue("p_about_me",NpgsqlDbType.Varchar, !string.IsNullOrEmpty(aboutMe) ? aboutMe : DBNull.Value);
                    command.Parameters.AddWithValue("p_specialization", specializationId.HasValue ? specializationId : DBNull.Value);
                    command.Parameters.AddWithValue("p_email", email);
                    command.Parameters.AddWithValue("p_phone", phone);

                    var result = (bool)command.ExecuteScalar();
                    return result;
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка исключения
            return false;
        }
    }


    // public bool UpdateUserProfile(int userId, string name, string aboutMe, int specializationId)
    // {
    //     try
    //     {
    //         using (var connection = new NpgsqlConnection(_connectionString))
    //         {
    //             connection.Open();
    //             using (var command = new NpgsqlCommand("SELECT update_user_profile(@p_user_id, @p_name, @p_about_me, @p_specialization)", connection))
    //             {
    //                 command.Parameters.AddWithValue("p_user_id", userId);
    //                 command.Parameters.AddWithValue("p_name", name);
    //                 command.Parameters.AddWithValue("p_about_me", aboutMe);
    //                 command.Parameters.AddWithValue("p_specialization", specializationId);

    //                 var result = (bool)command.ExecuteScalar();
    //                 return result;
    //             }
    //         }
    //     }
    //     catch (Exception ex)
    //     {
    //         // Обработка исключения
    //         return false;
    //     }
    // }


    public List<Course> GetCoursesByProfile(int profileId)
    {
        var courses = new List<Course>();
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT * FROM get_courses_by_profile(@p_profile_id)", connection))
                {
                    command.Parameters.AddWithValue("p_profile_id", profileId);

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var course = new Course
                            {
                                CategoryId = reader.GetInt32(0),
                                CategoryName = reader.GetString(1),
                                SectionId = reader.GetInt32(2),
                                SectionName = reader.GetString(3),
                                CourseId = reader.GetInt32(4),
                                CourseName = reader.GetString(5),
                                CourseDescription = reader.GetString(6),
                                CourseCreatedAt = reader.GetDateTime(7),
                                CourseClosed = reader.GetBoolean(8),
                                AccountId = reader.GetInt32(9)
                            };
                            courses.Add(course);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка исключения
        }
        return courses;
    }

    public Course GetCourseInfo(int courseId)
    {
        Course courseInfo = null;
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT * FROM get_course_info(@p_course_id)", connection))
                {
                    command.Parameters.AddWithValue("p_course_id", courseId);

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            courseInfo = new Course
                            {
                                CategoryId = reader.GetInt32(0),
                                CategoryName = reader.GetString(1),
                                SectionId = reader.GetInt32(2),
                                SectionName = reader.GetString(3),
                                CourseId = reader.GetInt32(4),
                                CourseName = reader.GetString(5),
                                CourseDescription = reader.GetString(6),
                                CourseCreatedAt = reader.GetDateTime(7),
                                CourseClosed = reader.GetBoolean(8),
                                AccountId = reader.GetInt32(9)
                            };
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка исключения
        }
        return courseInfo;
    }


    public List<Subsection> GetSubsections()
    {
        List<Subsection> Subsections = new();
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT * FROM get_all_sections()", connection))
                {

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Subsection Subsection = new Subsection
                            {
                                Id = reader.GetInt32(0),
                                Name = reader.GetString(1),

                            };
                            Subsections.Add(Subsection);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка исключения
        }
        return Subsections;
    }


    public bool UpdateCourse(int courseId, string courseName, int sectionId, string description, bool courseClosed)
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT update_course(@p_course_id, @p_course_name, @p_section_id, @p_description, @p_course_closed)", connection))
                {
                    command.Parameters.AddWithValue("p_course_id", courseId);
                    command.Parameters.AddWithValue("p_course_name", courseName);
                    command.Parameters.AddWithValue("p_section_id", sectionId);
                    command.Parameters.AddWithValue("p_description", description);
                    command.Parameters.AddWithValue("p_course_closed", courseClosed);

                    return (bool)command.ExecuteScalar();
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка исключения
            return false;
        }
    }


    public List<FormData> GetAllFormsTraining()
    {
        List<FormData> formDataList = new List<FormData>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_all_forms_training()", connection))
            {
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        FormData formData = new FormData
                        {
                            Id = reader.GetInt32(0), // Первый столбец - form_id
                            Name = reader.GetString(1) // Второй столбец - form_name
                        };
                        formDataList.Add(formData);
                    }
                }
            }
        }

        return formDataList;
    }


    public List<CityData> GetAllCities()
    {
        List<CityData> cityDataList = new List<CityData>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_all_cities()", connection))
            {
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        CityData cityData = new CityData
                        {
                            Id = reader.GetInt32(0), // Первый столбец - city_id
                            Name = reader.GetString(1) // Второй столбец - city_name
                        };
                        cityDataList.Add(cityData);
                    }
                }
            }
        }

        return cityDataList;
    }

    public List<StudyGroup> GetAllStudyGroupCourse(int courseId)
    {
        List<StudyGroup> groupList = new List<StudyGroup>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_study_groups_by_course_id(@p_course_id)", connection))
            {
                command.Parameters.AddWithValue("@p_course_id", courseId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        StudyGroup groupData = new StudyGroup
                        {
                            Id = reader.GetInt32(0),
                            Enrollment = reader.GetInt32(1),
                            StartDate = reader.GetDateTime(2),
                            EndDate = reader.IsDBNull(3) ? null : reader.GetDateTime(3),
                            Price = reader.GetDecimal(4),
                            FormsTrainingId = reader.GetInt32(5),
                            CityId = reader.GetInt32(6),
                            Duration = reader.GetInt32(7),
                            CourseId = reader.GetInt32(8),
                            AcceptedApplicationsCount = reader.GetInt32(9),
                            FormTraining = reader.IsDBNull(11) ? null : reader.GetString(11),
                            CityName = reader.IsDBNull(12) ? null : reader.GetString(12)

                        };
                        List<ScheduleDay> scheduleDays = JsonConvert.DeserializeObject<List<ScheduleDay>>(reader.GetString(10));
                        groupData.ScheduleDays = scheduleDays;
                        groupList.Add(groupData);
                    }
                }
            }
        }

        return groupList;
    }


    public StudyGroup GetStudyGroupCourseViewById(int createrId)
    {
        StudyGroup result = new();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_study_groups_by_creater_id(@p_creater_id)", connection))
            {
                command.Parameters.AddWithValue("@p_creater_id", createrId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result = new StudyGroup
                        {
                            Id = reader.GetInt32(0),
                            Enrollment = reader.GetInt32(1),
                            StartDate = reader.GetDateTime(2),
                            EndDate = reader.IsDBNull(3) ? null : reader.GetDateTime(3),
                            Price = reader.GetDecimal(4),
                            FormsTrainingId = reader.GetInt32(5),
                            CityId = reader.GetInt32(6),
                            Duration = reader.GetInt32(7),
                            CourseId = reader.GetInt32(8),
                            AcceptedApplicationsCount = reader.GetInt32(9),
                            FormTraining = reader.IsDBNull(11) ? null : reader.GetString(11),
                            CityName = reader.IsDBNull(12) ? null : reader.GetString(12)

                        };
                        List<ScheduleDay> scheduleDays = JsonConvert.DeserializeObject<List<ScheduleDay>>(reader.GetString(10));
                        result.ScheduleDays = scheduleDays;
                    }
                }
            }
        }

        return result;
    }


    public StudyGroup GetStudyGroupById(int groupId)
    {
        StudyGroup group = new();
        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_study_group_by_id(@p_group_id)", connection))
            {
                command.Parameters.AddWithValue("p_group_id", groupId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {

                        group.Id = reader.GetInt32(0);
                        group.Enrollment = reader.GetInt32(1);
                        group.StartDate = reader.GetDateTime(2);
                        if (!reader.IsDBNull(3))
                        {
                            group.EndDate = reader.GetDateTime(3);
                        }
                        else
                        {
                            group.EndDate = null;
                        }
                        group.Price = reader.GetDecimal(4);
                        group.FormsTrainingId = reader.GetInt32(5);
                        group.CityId = reader.GetInt32(6);
                        group.Duration = reader.GetInt32(7);
                        group.CourseId = reader.GetInt32(8);
                        group.AcceptedApplicationsCount = reader.GetInt32(9);


                        List<ScheduleDay> scheduleDays = JsonConvert.DeserializeObject<List<ScheduleDay>>(reader.GetString(10));
                        group.ScheduleDays = scheduleDays;
                    }
                }
            }
        }

        return group;
    }

    public List<ScheduleDay> GetAllDays()
    {
        List<ScheduleDay> days = new List<ScheduleDay>();

        try
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();

                // Создаем команду для вызова функции
                using (var cmd = new NpgsqlCommand("SELECT * FROM GetAllDays()", conn))
                {
                    // Выполняем команду
                    using (var reader = cmd.ExecuteReader())
                    {
                        // Обрабатываем результат запроса
                        while (reader.Read())
                        {
                            int id = reader.GetInt32(0); // Получаем значение из первого столбца
                            string name = reader.GetString(1); // Получаем значение из второго столбца

                            // Добавляем данные в список
                            days.Add(new ScheduleDay { Id = id, Name = name });
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Ошибка: {ex.Message}");
        }

        return days;
    }


    public bool UpdateStudyGroup(int id, int enrollment, DateTime startDate, DateTime? endDate, decimal price,
        int? formsTrainingId, int? cityId, int duration)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("select * from update_study_group(@p_id, @p_enrollment, @p_date_start, @p_date_end, @p_price, @p_id_forms_training, @p_id_city, @p_duration)", connection))
            {


                command.Parameters.AddWithValue("p_id", id);
                command.Parameters.AddWithValue("p_enrollment", enrollment);
                command.Parameters.AddWithValue("p_date_start", NpgsqlDbType.Date, startDate);
                command.Parameters.AddWithValue("p_date_end", NpgsqlDbType.Date, endDate.HasValue ? (object)endDate.Value : DBNull.Value);
                command.Parameters.AddWithValue("p_price", price);
                command.Parameters.AddWithValue("p_id_forms_training", formsTrainingId.HasValue ? formsTrainingId : DBNull.Value);
                command.Parameters.AddWithValue("p_id_city", cityId.HasValue ? cityId : DBNull.Value);
                command.Parameters.AddWithValue("p_duration", duration);

                var result = (bool)command.ExecuteScalar();
                return result;
            }
        }
    }

    public bool UpdateScheduleDays(int groupId, int[] dayIds)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("select * from update_schedule_days(@group_id, @day_ids)", connection))
            {

                command.Parameters.AddWithValue("group_id", groupId);
                command.Parameters.AddWithValue("day_ids", dayIds);

                var result = (bool)command.ExecuteScalar();
                return result;
            }
        }
    }


    public int CreateCourse(int profileId, string courseName, int sectionId, string description)
    {
        int insertedId = 0;

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            string sql = "SELECT create_course(@p_profile_id, @p_course_name, @p_section_id, @p_description)";

            using (NpgsqlCommand command = new NpgsqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@p_profile_id", profileId);
                command.Parameters.AddWithValue("@p_course_name", courseName);
                command.Parameters.AddWithValue("@p_section_id", sectionId);
                command.Parameters.AddWithValue("@p_description", description);

                insertedId = Convert.ToInt32(command.ExecuteScalar());
            }
        }

        return insertedId;
    }


    public void DeleteCourse(int courseId)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();


            using (var cmd = new NpgsqlCommand("CALL DeleteCourse(@courseId)", connection))
            {

                cmd.Parameters.AddWithValue("@courseId", courseId);


                cmd.ExecuteNonQuery();
            }
        }
    }

    public int CreateStudyGroup(int courseId, int enrollment, DateTime? dateStart, DateTime? dateEnd, decimal price, int formsTrainingId, int cityId, int duration)
    {
        int newGroupId = 0;

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT create_study_group(@p_enrollment, @p_date_start, @p_date_end, @p_price, @p_id_FormsTraining, @p_id_city, @p_duration, @p_id_course)", connection))
            {
                command.Parameters.AddWithValue("p_enrollment", NpgsqlDbType.Integer, enrollment);
                command.Parameters.AddWithValue("p_date_start", NpgsqlDbType.Date, dateStart.HasValue ? dateStart : DateTime.Now);
                command.Parameters.AddWithValue("p_date_end", NpgsqlDbType.Date, dateEnd.HasValue ? dateEnd : DBNull.Value);
                command.Parameters.AddWithValue("p_price", NpgsqlDbType.Numeric, price);
                command.Parameters.AddWithValue("p_id_FormsTraining", NpgsqlDbType.Integer, formsTrainingId);
                command.Parameters.AddWithValue("p_id_city", NpgsqlDbType.Integer, cityId);
                command.Parameters.AddWithValue("p_duration", NpgsqlDbType.Integer, duration);
                command.Parameters.AddWithValue("p_id_course", NpgsqlDbType.Integer, courseId);

                newGroupId = (int)command.ExecuteScalar();
            }
        }

        return newGroupId;
    }


    public int CreateApplication(int studyGroupId, string firstName, string lastName, string surname, string phone, DateTime birthday, string email)
    {
        int newId = 0;

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            string sql = "SELECT create_application(@p_id_StudyGroup, @p_firstName, @p_lastName, @p_surname, @p_phone, @p_birthday, @p_email)";

            using (NpgsqlCommand command = new NpgsqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@p_id_StudyGroup", NpgsqlDbType.Integer, studyGroupId);
                command.Parameters.AddWithValue("@p_firstName", NpgsqlDbType.Varchar, firstName);
                command.Parameters.AddWithValue("@p_lastName", NpgsqlDbType.Varchar, lastName);

                var surnameParam = new NpgsqlParameter("@p_surname", NpgsqlDbType.Varchar);
                surnameParam.Value = surname ?? (object)DBNull.Value;
                command.Parameters.Add(surnameParam);

                command.Parameters.AddWithValue("@p_phone", NpgsqlDbType.Varchar, phone);
                command.Parameters.AddWithValue("@p_birthday", NpgsqlDbType.Date, birthday);
                command.Parameters.AddWithValue("@p_email", NpgsqlDbType.Varchar, email);

                newId = Convert.ToInt32(command.ExecuteScalar());
            }
        }

        return newId;
    }

    public List<ApplicationDetails> GetApplications(int idCourse, int? idStatus = null)
    {
        var applications = new List<ApplicationDetails>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT * FROM get_applications(@p_id_course, @p_id_status)", connection))
            {
                command.Parameters.AddWithValue("p_id_course", idCourse);
                command.Parameters.AddWithValue("p_id_status", idStatus.HasValue ? (object)idStatus.Value : DBNull.Value);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var application = new ApplicationDetails
                        {
                            ApplicationId = reader.GetInt32(reader.GetOrdinal("application_id")),
                            FirstName = reader.GetString(reader.GetOrdinal("firstname")),
                            LastName = reader.GetString(reader.GetOrdinal("lastname")),
                            Surname = reader.IsDBNull(reader.GetOrdinal("surname")) ? null : reader.GetString(reader.GetOrdinal("surname")),
                            Phone = reader.GetString(reader.GetOrdinal("phone")),
                            Birthday = reader.GetDateTime(reader.GetOrdinal("birthday")),
                            Email = reader.GetString(reader.GetOrdinal("email")),
                            IdStatusApplications = reader.GetInt32(reader.GetOrdinal("id_statusapplications")),
                            created_at = reader.GetDateTime(reader.GetOrdinal("created_at")),
                            StudyGroupId = reader.GetInt32(reader.GetOrdinal("studygroup_id")),
                            Enrollment = reader.GetInt32(reader.GetOrdinal("enrollment")),
                            DateStart = reader.GetDateTime(reader.GetOrdinal("date_start")),
                            DateEnd = reader.IsDBNull(reader.GetOrdinal("date_end")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("date_end")),
                            Price = reader.IsDBNull(reader.GetOrdinal("price")) ? null : (decimal?)reader.GetDecimal(reader.GetOrdinal("price")),
                            Duration = reader.IsDBNull(reader.GetOrdinal("duration")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("duration")),
                            FormTrainingName = reader.IsDBNull(reader.GetOrdinal("form_training_name")) ? null : reader.GetString(reader.GetOrdinal("form_training_name")),
                            CityName = reader.IsDBNull(reader.GetOrdinal("city_name")) ? null : reader.GetString(reader.GetOrdinal("city_name")),
                            CourseId = reader.GetInt32(reader.GetOrdinal("course_id"))
                        };
                        applications.Add(application);
                    }
                }
            }
        }

        return applications;
    }


    public bool UpdateApplicationStatus(int applicationId, int newStatusId)
    {
        bool success = false;

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT update_application_status(@p_application_id, @p_new_status_id)", connection))
            {
                command.Parameters.AddWithValue("p_application_id", applicationId);
                command.Parameters.AddWithValue("p_new_status_id", newStatusId);


                // Выполняем запрос и получаем результат
                success = (bool)command.ExecuteScalar();
            }
        }

        return success;
    }


    public int DeleteStudyGroupById(int groupId)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT delete_study_group_by_id(@p_group_id)", connection))
            {
                command.Parameters.AddWithValue("p_group_id", groupId);

                try
                {
                    var result = command.ExecuteScalar();
                    return Convert.ToInt32(result);
                }
                catch (Exception ex)
                {
                    // Обработка ошибки
                    Console.WriteLine($"Error: {ex.Message}");
                    return 0;
                }
            }
        }
    }

    public int CreateProgramCourse(string name, string description, int courseId)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT create_program_course(@p_name, @p_description, @p_id_course)", connection))
            {
                command.Parameters.AddWithValue("@p_name", name);

                // Проверяем, является ли description null
                if (string.IsNullOrEmpty(description))
                {
                    command.Parameters.AddWithValue("@p_description", DBNull.Value);
                }
                else
                {
                    command.Parameters.AddWithValue("@p_description", description);
                }

                command.Parameters.AddWithValue("@p_id_course", courseId);

                var result = command.ExecuteScalar();
                return Convert.ToInt32(result);

            }
        }
    }

    public List<ProgramCourse> GetProgramsByCourseId(int courseId)
    {
        List<ProgramCourse> programs = new List<ProgramCourse>();

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT * FROM get_programs_by_course_id(@p_course_id)", connection))
            {
                command.Parameters.AddWithValue("p_course_id", courseId);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ProgramCourse program = new ProgramCourse
                        {
                            Id = reader.GetInt32(0),
                            Name = reader.GetString(1),
                            Description = reader.IsDBNull(2) ? null : reader.GetString(2),
                            CourseId = reader.GetInt32(3)
                        };
                        programs.Add(program);
                    }
                }
            }
        }

        return programs;
    }


    public bool UpdateProgramCourse(int id, string name, string description)
    {
        bool success = false;


        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT update_program_course(@p_id, @p_name, @p_description)", connection))
            {
                command.Parameters.AddWithValue("@p_id", NpgsqlDbType.Integer, id);
                command.Parameters.AddWithValue("@p_name", NpgsqlDbType.Varchar, name);
                if (string.IsNullOrEmpty(description))
                {
                    command.Parameters.AddWithValue("@p_description", NpgsqlDbType.Varchar, DBNull.Value);
                }
                else
                {
                    command.Parameters.AddWithValue("@p_description", NpgsqlDbType.Varchar, description);
                }

                var result = (bool)command.ExecuteScalar();
                success = result;
            }
        }


        return success;
    }


    public bool DeleteProgramCourse(int programId)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            try
            {
                connection.Open();

                using (var command = new NpgsqlCommand("SELECT delete_program_course(@program_id)", connection))
                {
                    command.Parameters.AddWithValue("@program_id", programId);

                    var result = command.ExecuteScalar();

                    if (result != null && result is bool success)
                    {
                        return success;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                return false;
            }
        }
    }


    public ResultPostgresData LoginAdmin(string login, string password)
    {
        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("SELECT * FROM login_admin(@p_login, @p_password)", connection))
            {
                command.Parameters.AddWithValue("p_login", login);
                command.Parameters.AddWithValue("p_password", password);


                command.ExecuteNonQuery();

                int resultId = Convert.ToInt32(command.ExecuteScalar());

                switch (resultId)
                {
                    case > 0:
                        return new ResultPostgresData(ResultPostgresStatus.Ok, resultId, "");
                    default:
                        return new ResultPostgresData(ResultPostgresStatus.ValidDataError, resultId, "Внутренния ошибка Б");
                }


            }
        }
    }


    public List<UserProfileInfo> GetUserProfilesInfo()
    {
        List<UserProfileInfo> userProfileInfos = new List<UserProfileInfo>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            string sql = "SELECT * FROM get_user_profiles_info()";

            using (NpgsqlCommand command = new NpgsqlCommand(sql, connection))
            {
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        UserProfileInfo userProfileInfo = new UserProfileInfo
                        {
                            AccountId = reader.GetInt32(0),
                            ProfileImageId = reader.IsDBNull(1) ? 0 : reader.GetInt32(1), // Проверка на NULL и присвоение значения по умолчанию
                            ProfileImage = reader.IsDBNull(2) ? string.Empty : reader.GetString(2), // Проверка на NULL и присвоение значения по умолчанию
                            Email = reader.GetString(3),
                            Phone = reader.GetString(4),
                            Name = reader.GetString(5),
                            AboutMe = reader.IsDBNull(6) ? string.Empty : reader.GetString(6), // Проверка на NULL и присвоение значения по умолчанию
                            SpecializationId = reader.IsDBNull(7) ? null : reader.GetInt32(7),
                            Specialization = reader.IsDBNull(8) ? string.Empty : reader.GetString(8),
                            LicenseNumber = reader.GetString(9),
                            Confirmation = reader.GetBoolean(10),
                            AccountCreatedAt = reader.GetDateTime(11)
                        };

                        userProfileInfos.Add(userProfileInfo);
                    }
                }
            }
        }

        return userProfileInfos;
    }


    public bool UpdateAccountConfirmation(int accountId, bool newConfirmation)
    {
        string sql = "SELECT update_account_confirmation(@p_account_id, @p_new_confirmation)";

        // Подключение к базе данных
        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            // Создание команды с SQL запросом
            using (NpgsqlCommand command = new NpgsqlCommand(sql, connection))
            {
                // Добавление параметров к запросу
                command.Parameters.AddWithValue("@p_account_id", accountId);
                command.Parameters.AddWithValue("@p_new_confirmation", newConfirmation);

                // Выполнение запроса
                object result = command.ExecuteScalar();

                // Проверка результата
                if (result != null && bool.TryParse(result.ToString(), out bool success))
                {
                    return success;
                }
            }
        }

        // В случае ошибки или неудачного обновления возвращаем false
        return false;
    }


    public List<BannedCourseView> GetAllBannedCourses()
    {
        List<BannedCourseView> bannedCourses = new List<BannedCourseView>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_all_banned_courses()", connection))
            {
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        BannedCourseView bannedCourse = new BannedCourseView();

                        bannedCourse.BanId = reader.GetInt32(0);
                        bannedCourse.Cause = reader.GetString(1);
                        bannedCourse.CourseId = reader.GetInt32(2);
                        bannedCourse.CourseName = reader.GetString(3);
                        bannedCourse.AdminId = reader.GetInt32(4);
                        bannedCourse.AdminName = reader.GetString(5);
                        bannedCourse.BannedAt = reader.GetDateTime(6);

                        bannedCourses.Add(bannedCourse);
                    }
                }
            }
        }

        return bannedCourses;
    }

    public bool DeleteBan(int banId)
    {

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();
            using (var command = new NpgsqlCommand("SELECT delete_ban_by_course_id(@p_course_id)", connection))
            {
                command.Parameters.AddWithValue("p_course_id", banId);

                var result = (bool)command.ExecuteScalar();
                return result;
            }
        }

    }

    public int AddBan(int courseId, int adminId, string reason)
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();

                using (var command = new NpgsqlCommand("SELECT add_ban(@courseId, @adminId, @reason)", connection))
                {
                    command.Parameters.AddWithValue("courseId", courseId);
                    command.Parameters.AddWithValue("adminId", adminId);
                    command.Parameters.AddWithValue("reason", reason);

                    var result = command.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка ошибок
            Console.WriteLine("Error: " + ex.Message);
            return 0;
        }
    }


    public bool IsCourseBanned(int courseId)
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();

                using (var command = new NpgsqlCommand("SELECT is_course_banned(@CourseId)", connection))
                {
                    command.Parameters.AddWithValue("CourseId", courseId);

                    var result = command.ExecuteScalar();

                    if (result != null && result is bool)
                    {
                        return (bool)result;
                    }

                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error checking if course is banned: " + ex.Message);
            return false;
        }
    }

    public List<CourseAndGroupView> getCourseStudyGroupsView(int courseId)
    {
        List<CourseAndGroupView> coursesAndGroups = new List<CourseAndGroupView>();


        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM get_course_instances(@p_course_id)", connection))
            {
                // Добавление параметров
                command.Parameters.AddWithValue("@p_course_id", NpgsqlDbType.Integer, courseId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        CourseAndGroupView courseAndGroup = new CourseAndGroupView();

                        courseAndGroup.CourseId = reader.GetInt32(0);
                        courseAndGroup.CourseName = reader.GetString(1);
                        courseAndGroup.CourseDescription = reader.GetString(2);
                        courseAndGroup.SectionId = reader.GetInt32(3);
                        courseAndGroup.SectionName = reader.GetString(4);
                        courseAndGroup.CreatorName = reader.GetString(5);
                        courseAndGroup.CreatorEmail = reader.GetString(6);
                        courseAndGroup.CreatorPhone = reader.GetString(7);
                        courseAndGroup.CreatorIsOrganization = reader.GetBoolean(8);
                        courseAndGroup.GroupId = reader.GetInt32(9);
                        courseAndGroup.GroupEnrollment = reader.GetInt32(10);
                        courseAndGroup.GroupDateStart = reader.GetDateTime(11);
                        courseAndGroup.GroupDateEnd = reader.IsDBNull(12) ? (DateTime?)null : reader.GetDateTime(12);
                        courseAndGroup.GroupPrice = reader.GetDecimal(13);
                        courseAndGroup.GroupDuration = reader.GetInt32(14);
                        courseAndGroup.AcceptedApplicationsCount = reader.GetInt32(15);
                        courseAndGroup.ScheduleDays = reader.GetString(16);
                        courseAndGroup.CourseClosed = reader.GetBoolean(17);

                        coursesAndGroups.Add(courseAndGroup);
                    }
                }
            }
        }


        return coursesAndGroups;
    }

    public ApplicationDetailsView? GetApplicationDetails(int applicationId)
    {
        ApplicationDetailsView? result = null;

        using (var connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            using (var command = new NpgsqlCommand("select * from GetApplicationDetails(@applicationId)", connection))
            {
                command.Parameters.AddWithValue("applicationId", applicationId);

                try
                {
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            result = new()
                            {
                                ApplicationId = reader.GetInt32(0),
                                GroupId = reader.GetInt32(1),
                                CourseId = reader.GetInt32(2),
                                CourseName = reader.GetString(3),
                                TrainingFormId = reader.GetInt32(4),
                                TrainingFormName = reader.GetString(5),
                                CityId = reader.GetInt32(6),
                                CityName = reader.GetString(7),
                                ApplicationStatusId = reader.GetInt32(8),
                                ApplicationStatusName = reader.GetString(9),
                                ApplicantEmail = reader.GetString(10),
                                CreatorProfileId = reader.GetInt32(11),
                                CreatorEmail = reader.GetString(12),
                                CreatorPhone = reader.GetString(13)
                            };
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"An error occurred: {ex.Message}");
                }
            }
        }

        return result;
    }


    public bool CheckAccountConfirmation(int userId)
    {
        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT check_account_confirmation(@p_user_id)", connection))
                {
                    command.Parameters.AddWithValue("p_user_id", userId);

                    // Выполняем запрос и получаем результат
                    bool isConfirmed = (bool)command.ExecuteScalar();

                    return isConfirmed;
                }
            }
        }
        catch (Exception ex)
        {
            // В случае ошибки возвращаем false
            return false;
        }
    }


    public List<CourseStatistics> GetCoursesPerSection()
    {
        List<CourseStatistics> courseStatisticsList = new List<CourseStatistics>();

        try
        {
            using (var connection = new NpgsqlConnection(_connectionString))
            {
                connection.Open();
                using (var command = new NpgsqlCommand("SELECT * FROM Get_Courses_PerSection()", connection))
                {
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            CourseStatistics courseStatistics = new CourseStatistics
                            {
                                SectionName = reader.GetString(0),
                                CourseCount = reader.GetInt32(1)
                            };
                            courseStatisticsList.Add(courseStatistics);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Обработка ошибок
            Console.WriteLine("Error: " + ex.Message);
        }

        return courseStatisticsList;
    }


    public List<ApplicationsPerCourse> GetCourseApplicationsStatisticsByCreatorId(int creatorId)
    {
        List<ApplicationsPerCourse> statistics = new List<ApplicationsPerCourse>();

        using (NpgsqlConnection connection = new NpgsqlConnection(_connectionString))
        {
            connection.Open();

            string sql = "SELECT * FROM GetCourseApplicationsStatisticsByCreatorId(@creatorId)";

            using (NpgsqlCommand command = new NpgsqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("creatorId", creatorId);

                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ApplicationsPerCourse stat = new ApplicationsPerCourse
                        {
                            CourseId = reader.GetInt32(0),
                            CourseName = reader.GetString(1),
                            ApplicationCount = reader.GetInt32(2),
                            CreatorId = reader.GetInt32(3)
                        };

                        statistics.Add(stat);
                    }
                }
            }
        }

        return statistics;
    }

}