function closeModal() {
  $("#type").prop("disabled", false);
  $("#type").val($("#type-toggle input:radio:checked").val());
  $("#exampleModalLong").modal("toggle");
}
$(document).ready(function () {
  let selectedEvent = "";
  let initialLoad = true;
  var calendar;
  getSelectedCalendar("camada");
  $("input[name=options]").change(function () {
    getSelectedCalendar(this.value);
  });

  // REAL TIME LISTENER
  db.collection('categories').onSnapshot(snapshot => {                
      let changes = snapshot.docChanges();
      changes.forEach(change => {
        var id = change.doc.id;       
        let item = '<a id="' + id + '" class="dropdown-item" href="#">' + id + '</a>';       
        $("#categoryDrop").append(item);
        let itemCategry = '<option value="' + id + '">' + id + '</option>';        
        $("#categorytype").append(itemCategry);
      });
      $(".dropdown-menu a").click(function(){
        var selText = $(this).text();
        $("#type-toggle .btn").removeClass("active");    
        var btn = $(this).parents('.btn-group').find('.dropdown-toggle');
        btn.addClass("active");
        btn.html(selText+'<span class="caret"></span>');
        getSelectedCalendar("categorias", selText + "_categorias");
      });
  }); 

  $("#type").change(function () {
    var typeVal= $(this).val();
    if(typeVal=="categorias") { 
      $("#categorySelect").css("display", "block");      
    } else {
      $("#categorySelect").css("display", "none");      
    }
    console.log(typeVal);
  });

  function getSelectedCalendar(type, collection) {
    if (collection==undefined) { 
      collection= type;
    }
    db.collection("calendar")
      .doc(type)
      .collection(collection + "_collection")
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
          let end = doc.data().end;
          let summary = doc.data().summary;
          // let date = Date(doc.data().timeStamp);
          //let date = doc.data().timeStamp.toDate();
          let event = {
            id,
            title: name,
            start: start ? new Date(start.seconds * 1000) : null,
            end: end ? formatDate(end.seconds * 1000) : null,
            allDay: allDay,
            className: className,
            summary,
            type,
          };
          console.log(event);

          calendarEvents.push(event);
        });
        if (initialLoad) {
          initializeCalendar(calendarEvents);
          initialLoad = false;
        } else {
          calendar.removeAllEvents();
          calendar.addEventSource(calendarEvents);
        }
      });
    // if (count == size - 1) {
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
    function initializeCalendar(events) {
      var calendarEl = document.getElementById("calendar-module");

      calendar = new FullCalendar.Calendar(calendarEl, {
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
          selectedEvent = info.event.id;
          $("#type").prop("disabled", true);
          $("#name").val(info.event.title);
          $("#description").val(info.event.extendedProps.summary);
          $("#type").val(info.event.extendedProps.type);
          if (info.event.start) {
            var day = ("0" + info.event.start.getDate()).slice(-2);
            var month = ("0" + (info.event.start.getMonth() + 1)).slice(-2);
            var hrs = info.event.start.getHours();
            var min = info.event.start.getMinutes();

            var today =
              info.event.start.getFullYear() + "-" + month + "-" + day;
            $("#start").val(today);

            $("#start_time").val(hrs < 10 ? `0${hrs}:${min}` : `${hrs}:${min}`);
          }
          if (info.event.end) {
            var day = ("0" + info.event.end.getDate()).slice(-2);
            var month = ("0" + (info.event.end.getMonth() + 1)).slice(-2);
            var hrs = info.event.end.getHours();
            var min = info.event.end.getMinutes();

            var today = info.event.end.getFullYear() + "-" + month + "-" + day;
            $("#end").val(today);
            $("#end_time").val(hrs < 10 ? `0${hrs}:${min}` : `${hrs}:${min}`);
          }
          $("#exampleModalLong").modal();
        },
      });

      calendar.render();
    }
  }

  $("#calendar-form").on("submit", function (e) {
    e.preventDefault();
    const name = $("#name").val();
    const desc = $("#description").val();
    const type = $("#type").val();
    var collection;
    if (type=="categorias") {      
      const categorytype = $("#categorytype").val();
      collection = categorytype + "_categorias_collection"      
    } else {  
      collection = type + "_collection";
    }
    const start = $("#start").val();
    const start_time = $("#start_time").val();
    var end = $("#end").val();
    const end_time = $("#end_time").val();
    console.log(start_time);

    const shrs = start_time.split(":")[0];
    const smin = start_time.split(":")[1];
    if (end && end_time) {
      const ehrs = end_time.split(":")[0];
      const emin = end_time.split(":")[1];      
      const _end = new Date(new Date(end).setHours(ehrs, emin, 0));
      end = _end.toString();
      //end.setHours(ehrs, emin, 0);
    }
    if (!selectedEvent) {
      db.collection("calendar")
        .doc(type)
        .collection(collection)
        .add({
          name,
          summary: desc,
          start: new Date(new Date(start).setHours(shrs, smin, 0)),
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
            start: new Date(new Date(start).setHours(shrs, smin, 0)),
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
