$(document).ready(function() {
    $('#editButton').click(function() {
        $('.edit-input').show();
        $('span').hide();
        $(this).hide();
        $('#saveButton').show();
        $('#cancelButton').show();
    });

    $('#cancelButton').click(function() {
        $('.edit-input').hide();
        $('span').show();
        $('#saveButton').hide();
        $('#cancelButton').hide();
        $('#editButton').show();
    });

    $('#saveButton').click(function() {
        var name = $('#nameInput').val();
        var aboutMe = $('#aboutMeInput').val();
        var specialization = $('#specializationInput option:selected').val();
        // Отправка AJAX-запроса
        $.ajax({
            url: '/СontrolPanel/Profile', // Укажите URL для обработчика сохранения профиля
            method: 'PUT',
            data: {
                name: name,
                aboutMe: aboutMe,
                specializationId: specialization
            },
            success: function(response) {
                // Обработка успешного ответа
                $('span#name').text(name);
                $('span#aboutMe').text(aboutMe);
                $('span#specialization').text($('#specializationInput option:selected').text());
                $('.edit-input').hide();
                $('span').show();
                $('#saveButton').hide();
                $('#cancelButton').hide();
                $('#editButton').show();
            },
            error: function(xhr, status, error) {
                // Обработка ошибки
                console.error(xhr.responseText);
            }
        });
    });
    
    // Показываем кнопку "Редактировать" при загрузке страницы
    $('#editButton').show();
});
