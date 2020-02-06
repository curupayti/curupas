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
            '<a class="nav-link" href="javascript:void(0);" ' + 
            'onclick="loadEditsList(\'' + _id + '\',\'' + _new + '\',\'' + _short + '\'); return false;">' + _name + '</a><span id="' + _id + '" class="badge badge-primary badge-pill">' + _amount + '</span></li>');                    
                   
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

    window.jsonData = [];
  
    window.loadEditsList = function(_id, _new, _short) { 

      window._short = _short;

      window._id = _id;
      
      clearFirepad();      

      var _doc = editObjects[_id];   
  
      _doc.ref.collection("collection").get()
      .then(function(querySnapshotEdit) {
  
           var editLength = querySnapshotEdit.docs.length;
  
           var countLines = 1;

           //Descargar con botones y usar un solo archivo
           //https://datatables.net/download/index

          if (window.datatable !=undefined ) {
            window.datatable.clear();            
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
              { "data": "meta.id" },
              { "data": "meta.Nombre" },
              { "data": "meta.Desc" },
              { "data": "meta.Actualizado" }
            ],
            columnDefs: [
              {
                "targets": [ 0 ],
                "visible": false,
                "searchable": false,                
              },
              {
                "targets": [ 1 ],
                "visible": false,
                "searchable": false,                
              },
              {
                "targets": [ 3 ],
                "visible": true,
                "searchable": true,
                "width": "50%"
              },
              {
                "targets": [ 4 ],
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
             
             let _date = editData.last_update;

             let last_update = getDateFrom(_date.toDate());
  
             let row = { "meta": {  "database_ref": editData.database_ref, "id": _id, "Nombre": editData.name, "Desc": editData.description.slice(0, 20) + "...", "Actualizado": last_update } };   
  
             window.jsonData.push(row);
  
             let database_ref = editData.database_ref;    
             
             if (editLength == countLines) {                                                            
                window.datatable.rows.add(window.jsonData);
                window.datatable.draw();    
             }
             
             countLines++;
         });
  
       });     
       
     }

     function getDateFrom(_date) {      

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

        window.datatable.clear();
        
        var new_name = $('#new-name').val();
        var new_desc = $('#new-desc').val();

        var document_path = "contents/" + window._short + "/collection";

        var _database_ref = makeid(28);        

        var _time =  new Date();

        var _desc = new_desc.slice(0, 20) + "...";

        var timestamp =  new Date();

        var thedate = getDateFrom(timestamp);            

        let row = { "meta": {  
          "database_ref": _database_ref, 
          "id" : window._id,
          "Nombre": new_name, 
          "Desc": new_desc, 
          "Actualizado": thedate } };   

        window.jsonData.push(row); 
        
        db.collection(document_path).add( {
          group_ref : _user.yearReference,
          name : new_name,
          description : new_desc,
          database_ref : _database_ref,
          last_update : _time        
        } ).then(function(document) {                                        
             
            window.datatable.rows.add(window.jsonData);
            window.datatable.draw(); 
              
            $('#addModal').modal('hide');

            $("#firepad-container").show();

            loadEdits(_database_ref, window._short);

            var num = parseInt($("#" + window._id).text());

            num++;

            $("#" + window._id).text(num);

        }).catch(function(error) {
          console.error("Error adding document: ", error);
        });   
        

     });

     function makeid(length) {
        var result           = '';
        var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
     }

     
     
    function loadEdits(database_ref, _short) {            

      var firepad_userlist_div = $( "<div id='firepad-userlist'></div>" );
      
      var firepad_div = $( "<div id='firepad'></div>" );
      
      $( "#firepad-container" ).append( firepad_userlist_div );
      $( "#firepad-container" ).append( firepad_div );    
  
      var firepad = null, userList = null, codeMirror = null;
  
      if (firepad) {
        // Clean up.
        firepad.dispose();
        userList.dispose();
        $('.CodeMirror').remove();
      }      
    
      var firepadRef = new Firebase( 'https://curupas-app.firebaseio.com/' + _short ).child(database_ref);

      codeMirror = CodeMirror(document.getElementById('firepad'), { lineWrapping: true });

      //LISTENER DRAG
      //https://groups.google.com/forum/#!topic/firepad-io/d9HRHfd9NcE

      firepad = Firepad.fromCodeMirror(firepadRef, codeMirror,
          { richTextToolbar: true, richTextShortcuts: true, userId: _user.userId});
      userList = FirepadUserList.fromDiv(firepadRef.child('users'),
          document.getElementById('firepad-userlist'), _user.userId);

        firepad.on('ready', function() {
          if (firepad.isHistoryEmpty()) {
            firepad.setText('Welcome to your own private pad!\n\nShare the URL below and collaborate with your friends.');
          }

          ensurePadInList(database_ref);
          buildPadList();
        });


        codeMirror.focus();
       

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

  

   
