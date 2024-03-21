$("#submit-form").on("click", function (e) {
  e.preventDefault();

  var form = $("form[name='form-main']");


  var formAction = form.attr("action");
  var formData = form.serialize();

  $.ajax({
    type: "POST",
    url: formAction,
    data: formData,
    success: function (response, textStatus, xhr) {
        if (xhr.status === 302) {
            
            window.location.href = xhr.getResponseHeader("Location");
          } else {
            
            //viewMessageError(response);
          }
    },
    error: function (xhr, status, error) {
      console.log("Ответ сервера:", response);
      viewMessageError(response.error);
    },
  });
});

function viewMessageError(msg) {
  $("#error-message").html(msg);
}
