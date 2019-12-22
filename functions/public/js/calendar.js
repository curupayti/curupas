$(document).ready(function () {       
      
    var calendarEl = document.getElementById('calendar-module');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      plugins: [ 'interaction', 'dayGrid', 'timeGrid', 'list' ],
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
      },
      defaultDate: '2019-08-12',
      navLinks: true, // can click day/week names to navigate views
      businessHours: true, // display business hours
      editable: true,
      events: [
        {
          title: 'Business Lunch',
          start: '2019-08-03T13:00:00',
          constraint: 'businessHours'
        },
        {
          title: 'Meeting',
          start: '2019-08-13T11:00:00',
          constraint: 'availableForMeeting', // defined below
          color: '#257e4a'
        },
        {
          title: 'Conference',
          start: '2019-08-18',
          end: '2019-08-20'
        },
        {
          title: 'Party',
          start: '2019-08-29T20:00:00'
        },

        // areas where "Meeting" must be dropped
        {
          groupId: 'availableForMeeting',
          start: '2019-08-11T10:00:00',
          end: '2019-08-11T16:00:00',
          rendering: 'background'
        },
        {
          groupId: 'availableForMeeting',
          start: '2019-08-13T10:00:00',
          end: '2019-08-13T16:00:00',
          rendering: 'background'
        },

        // red areas where no events can be dropped
        {
          start: '2019-08-24',
          end: '2019-08-28',
          overlap: false,
          rendering: 'background',
          color: '#ff9f89'
        },
        {
          start: '2019-08-06',
          end: '2019-08-08',
          overlap: false,
          rendering: 'background',
          color: '#ff9f89'
        }
      ]
    });

    calendar.render();
  });
    
    /*const monthNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
    ];

    const d = new Date();            
        
    var  year = new Date().getFullYear();
    var month = monthNames[d.getMonth()];

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
                start: date,
                allDay: allDay,
                className: className,
                editable: true,
                plugins: [ 'interaction' ]
            };

            calendarEvents.push(event);

            if (count == (size-1)) {                    
                initializeCalendar(calendarEvents);
            }
            count++;
        });

        function initializeCalendar(events) {

            var date = new Date();
            var d = date.getDate();
            var m = date.getMonth();
            var y = date.getFullYear();
           
            $('#external-events div.external-event').each(function() {
              // create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
              // it doesn't need to have a start or end
              var eventObject = {
                title: $.trim($(this).text()) // use the element's text as the event title
              };
              // store the Event Object in the DOM element so we can get to it later
              $(this).data('eventObject', eventObject);
              // make the event draggable using jQuery UI
              $(this).draggable({
                zIndex: 999,
                revert: true, // will cause the event to go back to its
                revertDuration: 0 //  original position after the drag
              });
            });
            
            /// initialize the calendar            
            var calendar = $('#calendar-module').fullCalendar({
              header: {
                left: 'title',
                center: 'agendaDay,agendaWeek,month',
                right: 'prev,next today'
              },
              editable: true,
              firstDay: 0, //  1(Monday) this can be changed to 0(Sunday) for the USA system
              selectable: true,
              defaultView: 'month',
              axisFormat: 'h:mm',
              columnFormat: {
                month: 'ddd', // Mon
                week: 'ddd d', // Mon 7
                day: 'dddd M/d', // Monday 9/7
                agendaDay: 'dddd d'
              },
              titleFormat: {
                month: 'MMMM yyyy', // September 2009
                week: "MMMM yyyy", // September 2009
                day: 'MMMM yyyy' // Tuesday, Sep 8, 2009
              },
              allDaySlot: false,
              selectHelper: true,
              select: function(start, end, allDay) {
                var title = prompt('Event Title:');
                if (title) {
                  calendar.fullCalendar('renderEvent', {
                      title: title,
                      start: start,
                      end: end,
                      allDay: allDay
                    },
                    true // make the event "stick"
                  );
                }
                calendar.fullCalendar('unselect');
              },
              droppable: true, // this allows things to be dropped onto the calendar !!!
              drop: function(date, allDay) { // this function is called when something is dropped
                // retrieve the dropped element's stored Event Object
                var originalEventObject = $(this).data('eventObject');
                // we need to copy it, so that multiple events don't have a reference to the same object
                var copiedEventObject = $.extend({}, originalEventObject);
                // assign it the date that was reported
                copiedEventObject.start = date;
                copiedEventObject.allDay = allDay;
                // render the event on the calendar
                // the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
                $('#calendar-module').fullCalendar('renderEvent', copiedEventObject, true);
                // is the "remove after drop" checkbox checked?
                if ($('#drop-remove').is(':checked')) {
                  // if so, remove the element from the "Draggable Events" list
                  $(this).remove();
                }
              },
              events: events, 
              dateClick: function(info) {
                  alert('Clicked on: ' + info.dateStr);
                  alert('Coordinates: ' + info.jsEvent.pageX + ',' + info.jsEvent.pageY);
                  alert('Current view: ' + info.view.type);
                  // change the day's background color just for fun
                  info.dayEl.style.backgroundColor = 'red';
              }       
          });          
       }
    });*/

       //# sourceURL=calendar.js   
//});
