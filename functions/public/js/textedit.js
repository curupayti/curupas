$(document).ready(function () {    

   homeLoader.show();
  

    var edit_references = _role.edit_references;

    for (let i = 0; i < edit_references.length; i++) {

      let editRef = edit_references[i]; 

      let refId = editRef.id;

      var count = 0;
      var flag = 0;

      db.collection("contents").doc(refId).get().then(function(_doc) {

          var data = _doc.data();

          var _id = _doc.id;

          let _name = data.name;  

          let _amount = data.amount;  
          
          let _time =  data.last_update;

          let _new =  data.new;

          let _short = data.short;
        
          //https://firebase.google.com/docs/firestore/solutions/presence?hl=es

          $("#edit-list").append(
            '<li class="list-group-item d-flex justify-content-between align-items-center">' +
            '<a id="' + _id + '" class="nav-link" href="javascript:void(0);" ' + 
            'onclick="loadEditsList(\'' + _id + '\',\'' + _new + '\',\'' + _short + '\'); return false;">' + _name + '</a><span class="badge badge-primary badge-pill">' + _amount + '</span></li>');           
          
          //editArray.push({'id':_id,'document':_doc}); 
          
          editObjects[_id] = _doc;

          if (length == (count-1)) {         

            homeLoader.hide();

          }       
          count++;      

      });   

      $('#edit-list li').click(function() { 
        $('li.list-group-item.active').removeClass("active"); 
        $(this).addClass("active"); 
      });
      
    }     
  
    window.loadEditsList = function(_id, _new, _short) { 

      window._short = _short;
      
      clearFirepad();      

      var _doc = editObjects[_id];   
  
      _doc.ref.collection("collection").get()
      .then(function(querySnapshotEdit) {
  
           var editLength = querySnapshotEdit.docs.length;
  
           var countLines = 1;
  
           var jsonData = [];

           //Descargar con botones y usar un solo archivo
           //https://datatables.net/download/index

          if (window.datatable !=undefined ) {
            window.datatable.clear();
            //window.datatable.buttons().remove()
            $('#new-button').text(_new);

          }

           window.datatable = $('#grid-details').DataTable( {
            scrollY: "180px",
            scrollCollapse: true,
            paging:         false,
            retrieve: true, 
            bInfo : false,                                                       
            columns: [
              { "data": "meta.database_ref" },
              { "data": "meta.Nombre" },
              { "data": "meta.Desc" },
              { "data": "meta.Actualizado" }
            ],
            columnDefs: [
              {
                "targets": [ 0 ],
                "visible": false,
                "searchable": false,
                "width": "30%"
              },
              {
                "targets": [ 2 ],
                "visible": true,
                "searchable": true,
                "width": "50%"
              },
              {
                "targets": [ 3 ],
                "visible": true,
                "searchable": true,
                "width": "20%"
              }
            ],    
            dom: 'Bfrtip',
            buttons: {
              buttons: [
                {
                  text: _new,
                  action: function(e, dt, node, config) 
                  {
                    $("#new-title").text(_new);
                    $('#addModal').modal('show');
                  },
                  attr:  {                    
                    id: 'new-button'
                  }
                }, 
                {
                  text: "Editar",
                  action: function(e, dt, node, config) 
                  {

                  },
                  attr:  {                    
                    id: 'edit-button',
                    disabled: true
                  }
                }
              ],
              dom: {
                button: {
                  tag: "button",                  
                  className: "btn btn-primary"
                },                
                buttonLiner: {
                  tag: null
                }
              }
            } 
          });        
    
          
          $('#grid-details tbody').on('click', 'tr', function () {
              var data = window.datatable.row( this ).data();
              //alert( 'You clicked on '+data.meta.id+'\'s row' );
              if ( $(this).hasClass('selected') ) {
                  $(this).removeClass('selected');
                  $("#edit-button").prop('disabled', true);
                  clearFirepad();            
                  $("#firepad-container").hide();
              }
              else {
                window.datatable.$('tr.selected').removeClass('selected');
                  $(this).addClass('selected');
                  $("#edit-button").removeAttr('disabled');
                  $("#firepad-container").show();
                  loadEdits(data.meta.database_ref, _short);                        
              }
              
          } );       
          
  
           querySnapshotEdit.forEach(function(docEdit) {
  
             var editData = docEdit.data();                  

             let last_update = getDateFrom(editData.last_update);
  
             let row = { "meta": {  "database_ref": editData.database_ref, "Nombre": editData.name, "Desc": editData.description.slice(0, 20) + "...", "Actualizado": last_update } };   
  
             jsonData.push(row);
  
             let database_ref = editData.database_ref;    
             
             if (editLength == countLines) {                                              
              
              window.datatable.rows.add(jsonData);
              window.datatable.draw();    
             }
             
             countLines++;
         });
  
       });     
       
     }

     function getDateFrom(date) {

      var _date = date.toDate();

      var year = _date.getFullYear();
      var month = _date.getMonth()+1;
      var day = _date.getDate();

      if (day < 10) {
        day = '0' + day;
      }
      if (month < 10) {
        month = '0' + month;
      }

      var formattedDate = day + '-' + month + '-' + year;

      return formattedDate;
     }

     function clearFirepad() {

        let hash_userlist = '#firepad-userlist';
        let hash_firepad = '#firepad';

        if($(hash_userlist).length){
          $( hash_userlist ).remove();
        }

        if($(hash_firepad).length){
          $( hash_firepad ).remove();
        } 
     }

     $("#add-form").submit(function (event) {
        event.preventDefault(); 
        
        var new_name = $('#new-name').val();
        var new_desc = $('#new-desc').val();

        var document_path = "contents/" + window._short + "/collection";

        var _database_ref = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

        var db_ref = database.ref(window._short).child(_id);

        var timestamp =  new Date();
        
        db.collection(document_path).add({
          group_ref: _user.yearReference,
          name: new_name,
          description: new_desc,
          database_ref : _database_ref,
          last_update: timestamp        
        })
        .then(function(document) { 

            let docRefId = document.id;  
            
            var _desc = new_desc.slice(0, 20) + "...";

            var thedate = getDateFrom(timestamp);

            let row = { "meta": {  
              "database_ref": _database_ref, 
              "Nombre": new_name, 
              "Desc": _desc, 
              "Actualizado": thedate } };                 

            window.datatable.row.add( [ row ] ).draw( false );    
              
            $('#addModal').modal('hide');

            $("#firepad-container").show();

            loadEdits(db_ref, window._short);

        }).catch(function(error) {
          console.error("Error adding document: ", error);
        });   
        

     });
     
     
    function loadEdits(database_ref, _short) {            

      var firepad_userlist_div = $( "<div id='firepad-userlist'></div>" );
      
      var firepad_div = $( "<div id='firepad'></div>" );
      
      $( "#firepad-container" ).append( firepad_userlist_div );
      $( "#firepad-container" ).append( firepad_div );
    
      var userId = _user.userId;
  
      var firepad = null, userList = null, codeMirror = null;
  
      if (firepad) {
        // Clean up.
        firepad.dispose();
        userList.dispose();
        $('.CodeMirror').remove();
      }
      
      var url = window.location.toString().replace(/#.*/, '') + '#' + id;     

      var id =  _user.userId;
      var firepadRef = database_ref; //database.ref(id);
      
      var url = window.location.toString().replace(/#.*/, '') + '#' + id;
      var firepadRef = new Firebase( 'https://curupas-app.firebaseio.com/' + _short ).child(id);

      var id = window.location.hash.replace(/#/g, '') || randomString(10);
      //var url = window.location.toString().replace(/#.*/, '') + '#' + id;
      var firepadRef = new Firebase(firebaseConfig.databaseURL).child(id);

      var userId = firepadRef.push().name(); // Just a random ID.
      codeMirror = CodeMirror(document.getElementById('firepad'), { lineWrapping: true });
      firepad = Firepad.fromCodeMirror(firepadRef, codeMirror,
          { richTextToolbar: true, richTextShortcuts: true, userId: userId});
      userList = FirepadUserList.fromDiv(firepadRef.child('users'),
          document.getElementById('firepad-userlist'), userId);

        firepad.on('ready', function() {
          if (firepad.isHistoryEmpty()) {
            firepad.setText('Welcome to your own private pad!\n\nShare the URL below and collaborate with your friends.');
          }

          ensurePadInList(id);
          buildPadList();
        });


        codeMirror.focus();

        window.location = url;
        $('#url').val(url);
        $("#url").on('click', function(e) {
          $(this).focus().select();
          e.preventDefault();
          return false;
        });

        setTimeout(function() {
          $(window).on('hashchange', joinFirepadForHash);
        }, 0);

      //}

      function padListEnabled() {
        return (typeof localStorage !== 'undefined' && typeof JSON !== 'undefined' && localStorage.setItem &&
            localStorage.getItem && JSON.parse && JSON.stringify);
      }

      function ensurePadInList(id) {
        if (!padListEnabled()) { return; }
        var list = JSON.parse(localStorage.getItem('demo-pad-list') || "{ }");
        if (!(id in list)) {
          var now = new Date();
          var year = now.getFullYear(), month = now.getMonth() + 1, day = now.getDate();
          var hours = now.getHours(), minutes = now.getMinutes();
          if (hours < 10) { hours = '0' + hours; }
          if (minutes < 10) { minutes = '0' + minutes; }

          list[id] = [year, month, day].join('/') + ' ' + hours + ':' + minutes;

          localStorage.setItem('demo-pad-list', JSON.stringify(list));
          buildPadList();
        }
      }

      function buildPadList() {
        if (!padListEnabled()) { return; }
        $('#my-pads-list').empty();

        var list = JSON.parse(localStorage.getItem('demo-pad-list') || '{ }');
        for(var id in list) {
          $('#my-pads-list').append(
              $('<div></div>').addClass('my-pads-item').append(
                  makePadLink(id, list[id])
          ));
        }
      }

      function makePadLink(id, name) {
        return $('<a></a>')
            .text(name)
            .on('click', function() {
              window.location = window.location.toString().replace(/#.*/, '') + '#' + id;
              $('#my-pads-list').hide();
              return false;
        });
      }

      function randomString(length) {
        var text = "";
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        for(var i=0; i < length; i++)
          text += possible.charAt(Math.floor(Math.random() * possible.length));

        return text;
      }

      /*$(window).on('ready', function() {
        joinFirepadForHash();
        setTimeout(function() {
          $(window).on('hashchange', joinFirepadForHash);
        }, 0);
      });*/

      function displayPads() {
        $('#my-pads-list').toggle();
      }

      function getFirepadById (firepadId) {

          var getFirePadFromRef = functions.httpsCallable('getFirePadFromRef');
          getFirePadFromRef({"refId": firepadId}).then(function(result) {
          
          var sanitizedMessage = result.data.text;

          console.log(sanitizedMessage);
          
        }).catch(function(error) {
          // Getting the Error details.
          var code = error.code;
          var message = error.message;
          var details = error.details;
          // ...
        });

      }

    }
      

      
    
  //# sourceURL=textedit.js   

  });

  

   
