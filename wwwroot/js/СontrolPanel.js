function setActiveNavItem(newActiveNavItem) {
  // Находим текущий активный элемент
  var currentActiveNavItem = $('[aria-current="page"]');
  
  // Если есть текущий активный элемент, удаляем у него атрибут aria-current и класс active
  if (currentActiveNavItem.length > 0) {
    currentActiveNavItem.removeAttr('aria-current');
    currentActiveNavItem.removeClass('active');
  }
  
  // Добавляем атрибут aria-current="page" и класс active новому активному элементу
  newActiveNavItem.attr('aria-current', 'page');
  newActiveNavItem.addClass('active');


  var page = newActiveNavItem.attr('data-page');
  switchPage(page);
}

// Пример использования:
$('#newActiveNavItem').click(function() {
  setActiveNavItem($(this));
});


$(document).ready(function() {
  // Обработчик для всех элементов с классом nav-link
  $('.btn-control').each(function() {
    $(this).click(function() {
      // Вызываем функцию для установки активного элемента
      setActiveNavItem($(this));
    });
  });

  // Обработчик для всех элементов с классом dropdown-item
  $('.btn-control').each(function() {
    $(this).click(function() {
      // Вызываем функцию для установки активного элемента
      setActiveNavItem($(this));
    });
  });
});


function switchPage(page) {
  $.ajax({
    type: "GET",
    url: `/СontrolPanel/${page}`,
    data: {},
    success: function (response, textStatus, xhr) {
      $('#container-main-content').html(response);
    },
    error: function (xhr, status, error) {
      console.log("Ответ сервера:", response);
      viewMessageError(response.error);
    },
  });
}
