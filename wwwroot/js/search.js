$("#SearchButton").on("click", function (e) {
  e.preventDefault();

  var form = document.getElementById("FormSearch"); // Получаем элемент формы по его идентификатору
  var formData = new FormData(form); // Создаем объект FormData и передаем в него форму

  // // Добавляем дополнительный параметр в объект FormData
  // formData.append("additionalParam", "additionalValue");

  // Преобразуем объект FormData в строку для отправки на сервер
  var serializedFormData = new URLSearchParams(formData).toString();

  $.ajax({
    type: "POST",
    url: "/Home/Search",
    data: serializedFormData,
    success: function (response) {
      console.log(response);
      createCourseCards(response);
    },
    error: function (xhr, status, error) {
      console.log("Ответ сервера:", response);
      //viewMessageError(response.error);
    },
  });
});

$(".dropdown-item").click(function () {
  var sectionId = $(this).data("sectionid");
  // Теперь вы можете использовать переменную sectionId для выполнения дальнейших действий

  $.ajax({
    type: "POST",
    url: `/Home/SearchSection/${sectionId}`,

    // data: sectionId,
    success: function (response) {
      console.log(response);
      createCourseCards(response);
    },
    error: function (xhr, status, error) {
      console.log("Ответ сервера:", response);
      //viewMessageError(response.error);
    },
  });
});

function createCourseCards(data) {
  // Очищаем контейнер перед добавлением новых карточек
  $("#CardsCourses").empty();

  if (data === null || data === undefined || data.length === 0) {
    $("#StatusSearch").text("Результат не найден");
  } else {
    $("#StatusSearch").text(""); // Очищаем статус, если результаты найдены

    // Перебираем каждый объект в массиве данных
    data.forEach((course) => {
      let scheduleString = "";
      try {
        const scheduleDaysArray = JSON.parse(course.scheduleDays);
        if (Array.isArray(scheduleDaysArray)) {
          scheduleDaysArray.forEach((day) => {
            scheduleString += day.name + " ";
          });
        }

        if (scheduleDaysArray.length == 0) {
          scheduleString = "дни неопределены";
        }
      } catch (error) {
        console.error("Ошибка при разборе данных о днях недели:", error);
      }

      var cardHtml = `
      <div class="col mb-4">
        <div class="card h-100">
          <div class="card-body">
            <a  class="card-title fs-2 link-dark text-break text-decoration: none; fw-bold text-100" style="" href="/Home/CourseHome/${
              course.courseId
            }">${course.courseName}</a>
            <p class="card-text text-break text-100">${
              course.courseDescription
            }</p>
            <table class="table">
              <tbody>
                <tr>
                  <td class="fw-medium">Категория:</td>
                  <td>${course.sectionName}</td>
                </tr>
                <tr>
                  <td class="fw-medium" >Дни обучения:</td>
                  <td>${scheduleString}</td>
                </tr>
                <tr>
                  <td class="fw-medium" >Цена:</td>
                  <td>${course.groupPrice} BYN</td>
                </tr>
                <tr>
                  <td class="fw-medium">Набор:</td>
                  <td>${course.acceptedApplicationsCount} / ${
        course.groupEnrollment
      }</td>
                </tr>
                <tr>
                  <td class="fw-medium" >Дата старта обучения:</td>
                  <td>${new Date(
                    course.groupDateStart
                  ).toLocaleDateString()}</td>
                </tr>
                <tr>
                  <td class="fw-medium" >Город:</td>
                  <td>${course.cityName || "не определено"}</td>
                </tr>
                <tr>
                  <td class="fw-semibold" >Создатель:</td>
                  <td>${course.creatorName}</td>
                </tr>
                <tr>
                  <td class="fw-semibold" >Курс от:</td>
                  <td>${
                    course.creatorIsOrganization
                      ? "организации"
                      : "преподавателя"
                  }</td>
                </tr>
                <tr>
                  <td class="fw-semibold" >Тип обучения:</td>
                  <td>${course.formTrainingName || "не определено"}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;
      // Добавляем созданный HTML-код карточки в контейнер
      $("#CardsCourses").append(cardHtml);
    });
  }

  truncateText(".text-100", 100);
}

function truncateText(selector, maxLength) {
  const elements = document.querySelectorAll(selector);

  elements.forEach((element) => {
    const text = element.textContent;

    if (text.length > maxLength) {
      const truncated = text.substring(0, maxLength) + "...";
      element.textContent = truncated;
    }
  });
}
