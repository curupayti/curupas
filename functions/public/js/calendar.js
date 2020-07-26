$(document).ready(function () {
  let selectedEvent = "";

  getSelectedCalendar("camada");
  $("input[name=options]").change(function () {
    getSelectedCalendar(this.value);
  });

  function getSelectedCalendar(type) {
    db.collection("calendar")
      .doc(type)
      .collection(type + "_collection")
      .get()
      .then((response) => {
        var calendarEvents = [];
        response.docs.forEach((doc) => {
          // let doc = change.doc;
          let id = doc.id;
          let name = doc.data().name;
          let className = doc.data().className;
          let allDay = doc.data().allDay;
          let start = doc.data().start;
          let summary = doc.data().summary;
          // let date = Date(doc.data().timeStamp);
          //let date = doc.data().timeStamp.toDate();

          let event = {
            id,
            title: name,
            start: formatDate(start.seconds * 1000),
            allDay: allDay,
            className: className,
            summary,
            type,
          };
          console.log(event);

          calendarEvents.push(event);
        });

        // if (count == size - 1) {
        initializeCalendar(calendarEvents);
        // }
        // count++;

        // let size = snapshot.size;
        // var count = 0;
        // let changes = snapshot.docChanges();

        // changes.forEach((change) => {
        //   let doc = change.doc;
        //   let name = doc.data().name;
        //   let className = doc.data().className;
        //   let allDay = doc.data().allDay;
        //   let start = doc.data().start;
        //   let date = Date(doc.data().timeStamp);
        //   //let date = doc.data().timeStamp.toDate();

        //   let event = {
        //     title: name,
        //     start: formatDate(start.seconds * 1000),
        //     allDay: allDay,
        //     className: className,
        //   };

        //   calendarEvents.push(event);

        //   if (count == size - 1) {
        //     initializeCalendar(calendarEvents);
        //   }
        //   count++;
        // });
      });
    function initializeCalendar(events) {
      var calendarEl = document.getElementById("calendar-module");

      var calendar = new FullCalendar.Calendar(calendarEl, {
        plugins: ["interaction", "dayGrid", "timeGrid", "list"],
        header: {
          left: "prev,next today",
          center: "title",
          right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth",
        },
        //defaultDate: '2019-08-12',
        navLinks: true, // can click day/week names to navigate views
        businessHours: true, // display business hours
        editable: true,
        locale: "es",
        monthNames: [
          "Enero",
          "Febrero",
          "Marzo",
          "Abril",
          "Mayo",
          "Junio",
          "Julio",
          "Agosto",
          "Septiembre",
          "Octubre",
          "Noviembre",
          "Diciembre",
        ],
        monthNamesShort: [
          "Ene",
          "Feb",
          "Mar",
          "Abr",
          "May",
          "Jun",
          "Jul",
          "Ago",
          "Sep",
          "Oct",
          "Nov",
          "Dic",
        ],
        dayNames: [
          "Domingo",
          "Lunes",
          "Martes",
          "Miércoles",
          "Jueves",
          "Viernes",
          "Sábado",
        ],
        dayNamesShort: ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"],
        events: events,
        eventClick: function (info) {
          console.log(info.event);
          selectedEvent = info.event.id;
          $("#type").prop("disabled", true);
          $("#name").val(info.event.title);
          $("#description").val(info.event.extendedProps.summary);
          $("#type").val(info.event.extendedProps.type);
          if (info.event.start) {
            var day = ("0" + info.event.start.getDate()).slice(-2);
            var month = ("0" + (info.event.start.getMonth() + 1)).slice(-2);

            var today =
              info.event.start.getFullYear() + "-" + month + "-" + day;
            $("#start").val(today);
          }
          if (info.event.end) {
            var day = ("0" + info.event.end.getDate()).slice(-2);
            var month = ("0" + (info.event.end.getMonth() + 1)).slice(-2);

            var today = info.event.end.getFullYear() + "-" + month + "-" + day;
            $("#end").val(today);
          }
          $("#exampleModalLong").modal();
        },
      });

      calendar.render();
    }
  }

  function formatDate(date) {
    var d = new Date(date),
      month = "" + (d.getMonth() + 1),
      day = "" + d.getDate(),
      year = d.getFullYear();

    if (month.length < 2) month = "0" + month;
    if (day.length < 2) day = "0" + day;
    return [year, month, day].join("-");
  }

  $("#calendar-form").on("submit", function (e) {
    e.preventDefault();
    const name = $("#name").val();
    const desc = $("#description").val();
    const type = $("#type").val();
    const start = $("#start").val();
    const end = $("#end").val();
    if (!selectedEvent) {
      db.collection("calendar")
        .doc(type)
        .collection(type + "_collection")
        .add({
          name,
          summary: desc,
          start: new Date(start),
          end: end ? new Date(end) : null,
          createdAt: new Date(),
        })
        .then((res) => {
          $("#name").val("");
          $("#description").val("");
          $("#start").val("");
          $("#end").val("");
          $("#exampleModalLong").modal("toggle");
          alert("Event Added");
        });
    } else {
      db.collection("calendar")
        .doc(type)
        .collection(type + "_collection")
        .doc(selectedEvent)
        .set(
          {
            name,
            summary: desc,
            start: new Date(start),
            end: end ? new Date(end) : null,
          },
          { merge: true }
        )
        .then(() => {
          $("#name").val("");
          $("#description").val("");
          $("#start").val("");
          $("#type").prop("disabled", false);
          $("#end").val("");
          $("#exampleModalLong").modal("toggle");
          selectedEvent = "";
          alert("Event Updated");
        });
    }
  });

  //# sourceURL=calendar.js
});
