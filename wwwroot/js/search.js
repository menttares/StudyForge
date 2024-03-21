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

$("#search").on("click", function (e) {
  e.preventDefault();

  var form = $("form[name='search']");
  var formData = form.serialize();

  $.ajax({
    type: "POST",
    url: "/Courses/Search",
    data: formData,
    success: function (response) {
      //console.log(response);
      loadData(response);
    },
    error: function (xhr, status, error) {
      console.log("Ответ сервера:", response);
      //viewMessageError(response.error);
    },
  });
});

$(".catalog-container__option").each(function () {
  $(this).click(function (e) {
    // Обработчик нажатия кнопки
    //e.preventDefault();
    var optionText = $(this).text();
    var dataId = $(this).data("id");
    console.log(dataId);
    $.ajax({
      type: "GET",
      url: `/Courses/SearchCategory`,
      data: {
        Categoryid : dataId
      },
      success: function (response) {
        //console.log(response);
        loadData(response);
      },
      error: function (xhr, status, error) {
        console.log("Ответ сервера:", response);
        //viewMessageError(response.error);
      },
    });
  });
});

function loadData(data) {
  let main = document.getElementById("main-content");
  main.innerHTML = "";
  let Newdata = JSON.parse(data);
  Newdata.forEach((el) => {
    let newElem = createCourseElement(el);
    //console.log(el);
    main.appendChild(newElem);
  });
}

function createCourseElement(el) {
  console.log(el);
  // Создаем основной элемент course
  var courseElement = document.createElement("div");
  courseElement.classList.add("course");

  // Создаем элементы title и description
  var titleElement = document.createElement("a");
  titleElement.href = `/Course/${el.CourseId}`;
  titleElement.classList.add("course__title");
  titleElement.textContent = el["CourseName"];
  courseElement.appendChild(titleElement);

  var descriptionElement = document.createElement("div");
  descriptionElement.classList.add("course__description");
  descriptionElement.textContent = el["CourseDescription"];
  courseElement.appendChild(descriptionElement);

  // Создаем таблицу course-table и ее содержимое
  var tableElement = document.createElement("div");
  tableElement.classList.add("course-table");

  var tableRows = [
    {
      label: "Набор:",
      value: `${el.AcceptedApplicationsCount}/${el.Enrollment}`,
    },
    { label: "учебные дни:", value: el.StudyDays },
    { label: "форма обучения:", value: el.FormOfStudyName },
    { label: "город:", value: el.CityName },
    { label: "длительность:", value: el.FormOfStudyName },
    { label: "дата старта набора:", value: el.DateStart },
  ];

  tableRows.forEach(function (rowData) {
    var rowElement = document.createElement("div");
    rowElement.classList.add("course-table__row");

    var colLabelElement = document.createElement("div");
    colLabelElement.classList.add("course-table__col", "col-bold");
    colLabelElement.textContent = rowData.label;
    rowElement.appendChild(colLabelElement);

    var colValueElement = document.createElement("div");
    colValueElement.classList.add("course-table__col");
    colValueElement.textContent = rowData.value;
    rowElement.appendChild(colValueElement);

    tableElement.appendChild(rowElement);
  });

  courseElement.appendChild(tableElement);

  // Создаем блок course-price
  var priceContainerElement = document.createElement("div");
  priceContainerElement.classList.add("course-price__container");

  var priceBlockElement = document.createElement("div");
  priceBlockElement.classList.add("course-price__blok");

  var priceFlexElement = document.createElement("div");
  priceFlexElement.classList.add("price-flex");

  var priceTitleElement = document.createElement("div");
  priceTitleElement.classList.add("course-price__title");
  priceTitleElement.textContent = "Цена";
  priceFlexElement.appendChild(priceTitleElement);

  var priceCurrencyElement = document.createElement("div");
  priceCurrencyElement.classList.add("course-price__currency");
  var currencyValueElement = document.createElement("span");
  currencyValueElement.textContent = el.Price;
  var currencyTextElement = document.createElement("span");
  currencyTextElement.textContent = "BYN";
  priceCurrencyElement.appendChild(currencyValueElement);
  priceCurrencyElement.appendChild(currencyTextElement);

  priceFlexElement.appendChild(priceCurrencyElement);
  priceBlockElement.appendChild(priceFlexElement);

  var priceSubtitleElement = document.createElement("div");
  priceSubtitleElement.classList.add("course-price__subtitle");
  priceSubtitleElement.textContent = "полная стоимость";
  priceBlockElement.appendChild(priceSubtitleElement);

  priceContainerElement.appendChild(priceBlockElement);
  courseElement.appendChild(priceContainerElement);

  // Создаем блок course-organizer
  var organizerElement = document.createElement("div");
  organizerElement.classList.add("course-organizer");

  var organizerTitleElement = document.createElement("div");
  organizerTitleElement.classList.add("course-organizer__title");
  organizerTitleElement.textContent = el.ProfileName;
  organizerElement.appendChild(organizerTitleElement);

  var organizerSubtitleElement = document.createElement("div");
  organizerSubtitleElement.classList.add("course-organizer__subtitle");
  if (el.IsOrganization == true) {
    organizerSubtitleElement.textContent = "организация";
  } else {
    organizerSubtitleElement.textContent = "преподаватель";
  }
  organizerElement.appendChild(organizerSubtitleElement);

  courseElement.appendChild(organizerElement);

  // Возвращаем сформированный элемент course
  return courseElement;
}

// Пример использования функции
var courseElement = createCourseElement();
document.body.appendChild(courseElement); // Добавляем созданный элемент в DOM
