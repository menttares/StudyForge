// $(function(){

//   $.ajax({
//     type: "POST",
//     url: "/Course",
//     data: {id : },
//     success: function (response) {
//       //console.log(response);
//       console.log(response);
//     },
//     error: function (xhr, status, error) {
//       console.log("Ответ сервера:", response);
//       //viewMessageError(response.error);
//     },
//   });
// });

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
          scheduleDaysArray.forEach(day => {
            scheduleString += day.name + " ";
          })
          ;
        }

        if (scheduleDaysArray.length == 0) {
          scheduleString ="дни неопределены"
        }

      } catch (error) {
        console.error("Ошибка при разборе данных о днях недели:", error);
      }



      var cardHtml = `
<div class="col mb-4">
  <div class="card h-100">
    <div class="card-body">
      <a class="card-title fs-2 link-dark link-offset-3 text-break" href="/Home/CourseHome/${course.courseId}">${
        course.courseName
      }</a>
      <p class="card-text text-break">${course.courseDescription}</p>
      <table class="table">
        <tbody>
          <tr>
            <td>Категория:</td>
            <td>${course.sectionName}</td>
          </tr>
          <tr>
          <td>Дни обучения:</td>
          <td>${ scheduleString}</td>
        </tr>
          <tr>
            <td>Цена:</td>
            <td>${course.groupPrice}</td>
          </tr>
          <tr>
            <td>Набор:</td>
            <td>${course.acceptedApplicationsCount} / ${
        course.groupEnrollment
      }</td>
          </tr>
          <tr>
            <td>Дата старта:</td>
            <td>${new Date(course.groupDateStart).toLocaleDateString()}</td>
          </tr>
          <tr>
            <td>Дата окончания:</td>
            <td>${new Date(course.groupDateEnd).toLocaleDateString()}</td>
          </tr>
          <tr>
            <td>Создатель:</td>
            <td>${course.creatorName}</td>
          </tr>
          <tr>
            <td>Тип создателя:</td>
            <td>${
              course.creatorIsOrganization ? "организация" : "преподаватель"
            }</td>
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
}
