var activeIdform = null;

$(document).ready(function () {
  // Получаем текущую дату
  var currentDate = new Date();

  // Вычитаем 18 лет из текущей даты
  var minDate = new Date(
    currentDate.getFullYear() - 18,
    currentDate.getMonth(),
    currentDate.getDate()
  );

  // Преобразуем минимальную дату в формат YYYY-MM-DD для установки в атрибуте min
  var minDateString = minDate.toISOString().slice(0, 10);

  // Устанавливаем минимальную дату в поле ввода даты
  document.getElementById("birthday").max = minDateString;

  $(".event-click-group").each(function () {
    $(this).click(function () {
      var attributeValue = $(this).attr("data-id");
      activeIdform = attributeValue;
      $("#myModal").css("display", "block");
    });
  });

  $("#submitButton").click(function (e) {
    e.preventDefault(); // Предотвращаем отправку формы по умолчанию

    var formDataArray = $("#applicationForm").serializeArray();
    formDataArray.push({ name: "StudyGroupId", value: activeIdform });
    // Преобразуем массив обратно в строку для отправки на сервер
    var formData = $.param(formDataArray);

    // Отправляем данные на сервер
    $.ajax({
      type: "POST",
      url: "/Courses/Recording", // URL адрес, на который отправляем данные
      data: formData, // Данные формы
      success: function (response) {
        // Обработка успешного ответа от сервера
        var $button = $(".event-click-group[data-id='" + activeIdform + "']");
        $button.text("Отправлено");
        $button.attr("disabled", true);
        $button.css("background-color","green")
        closeModal();
      },
      error: function (xhr, status, error) {
        // Обработка ошибки
        console.error("Error:", error);
      },
    });
  });
});

function closeModal() {
  $("#myModal").css("display", "none");
}
