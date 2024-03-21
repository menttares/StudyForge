$(document).ready(function () {
  $(".panel__option").each(function () {
    $(this).click(function (e) {
      e.preventDefault();
      $(this).removeClass("active-link");

      var page = $(this).attr("data-page");
      $.ajax({
        type: "GET",
        url: `/ManagementCourse/${page}`, // URL адрес, на который отправляем данные
        success: function (response) {
          // Обработка успешного ответа от сервера
          //console.log("Success:", response);
          $("#main-page").html("");
          $("#main-page").html(response);
        },
        error: function (xhr, status, error) {
          // Обработка ошибки
          console.error("Error:", error);
          $("#main-page").html("");
        },
      });
    });
  });

  $(".panel__option").click(function (e) {
    $(".panel__option").each(function () {
      $(this).removeClass("active-link");
    });
    $(this).addClass("active-link");
  });
});
