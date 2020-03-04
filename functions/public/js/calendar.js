$(document).ready(function () {       
      
  var calendarEvents = [];  

  db.collection('calendar').onSnapshot(snapshot => {
      
      let size = snapshot.size;
      var count = 0;
      let changes = snapshot.docChanges();

      changes.forEach(change => {
          
          let doc = change.doc;
          let name = doc.data().name;
          let className = doc.data().className;
          let allDay = doc.data().allDay;
          let start = doc.data().start;
          let date = Date(doc.data().timeStamp); 
          //let date = doc.data().timeStamp.toDate();

          let event = {
              title: name,
              start: formatDate(date),
              allDay: allDay,
              className: className              
          };

          calendarEvents.push(event);

          if (count == (size-1)) {                    
              initializeCalendar(calendarEvents);
          }
          count++;
      });
  });  

  function initializeCalendar(events) {

    var calendarEl = document.getElementById('calendar-module');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      plugins: [ 'interaction', 'dayGrid', 'timeGrid', 'list' ],
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
      },
      //defaultDate: '2019-08-12',
      navLinks: true, // can click day/week names to navigate views
      businessHours: true, // display business hours
      editable: true,
      locale: 'es',
      monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
      monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
      dayNames: ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'],
      dayNamesShort: ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'],
      events: events, 
    });

    calendar.render();

  }

  function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) 
        month = '0' + month;
    if (day.length < 2) 
        day = '0' + day;
    return [year, month, day].join('-');
  }

  //# sourceURL=calendar.js   
  
});
    
    