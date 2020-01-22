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
          
          let _time =  data.last_update;
        
          //https://firebase.google.com/docs/firestore/solutions/presence?hl=es

          $("#edit-list").append('<li class="list-group-item"><a id="' + _id + '" class="nav-link" href="javascript:void(0);" onclick="loadEditsList(\'' + _id + '\'); return false;">' + _name + '</a></li>');           
          
          //editArray.push({'id':_id,'document':_doc}); 

          editObjects[_id] = _doc;

          if (length == (count-1)) {         

            homeLoader.hide();

          }       
          count++;        

          /*collection.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
        
          
              });
          });*/
        
      });   
      
    }         
  
  
    function loadEdits(jsonData) { 
    
      var userId = _user.userId;
  
      var firepad = null, userList = null, codeMirror = null;
  
      //function joinFirepadForHash() {
  
        $('#edit-list li').click(function() { 
          $('li.list-group-item.active').removeClass("active"); 
          $(this).addClass("active"); 
        });       
  
        
  
        //var table = $("#grid-edits").DataTable();
        //table.clear();
  
        if (firepad) {
          // Clean up.
          firepad.dispose();
          userList.dispose();
          $('.CodeMirror').remove();
        }
  
        //var id = window.location.hash.replace(/#/g, '') || randomString(10);
        var url = window.location.toString().replace(/#.*/, '') + '#' + id;
        //var firepadRef = new Firebase('https://firepad.firebaseio.com/demo').child(id);
  
        var id =  _user.userId;
        var firepadRef = database.ref(id);
  
        //var id = window.location.hash.replace(/#/g, '') || randomString(10);
        var url = window.location.toString().replace(/#.*/, '') + '#' + id;
        var firepadRef = new Firebase('https://firepad.firebaseio.com/demo').child(id);
  
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
      

      window.loadEditsList = function(_id) {

        var _doc = editObjects[_id];   
    
        _doc.ref.collection("collection").get()
        .then(function(querySnapshotEdit) {
    
             var editLength = querySnapshotEdit.docs.length;
    
             var countLines = 1;
    
             var jsonData = [];

             var datatable = $('#grid-details').DataTable( {
              "scrollY":        "150px",
              "scrollCollapse": true,
              "paging":         false,
              //"data": jsonData,
              "columns": [
                { "data": "meta.Nombre" },
                { "data": "meta.Actualizado" }
              ]
            });
    
             querySnapshotEdit.forEach(function(docEdit) {
    
               var editData = docEdit.data();     

               var last_update = editData.last_update;
               
                var _date = last_update.toDate();

                var year = _date.getFullYear();
                var month = _date.getMonth()+1;
                var day = _date.getDate();

                if (day < 10) {
                  day = '0' + day;
                }
                if (month < 10) {
                  month = '0' + month;
                }

                var formattedDate = day + '-' + month + '-' + year
    
               let row = { "meta": { "Nombre": editData.name, "Actualizado": formattedDate} };   
    
               jsonData.push(row);
    
               let database_ref = editData.database_ref;    
               
               if (editLength == countLines) {                               
                  
                  datatable.clear();
                  datatable.rows.add(jsonData);
                  datatable.draw();    
               }
               
               countLines++;
           });
    
         });     
         
       }
    
  //# sourceURL=textedit.js   

  });

  

   
