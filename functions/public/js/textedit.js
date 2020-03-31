$(document).ready(function () {        

    homeLoader.show();  

    window.jsonDataMain = [];

    var edit_references = _role.edit_references;

    for (let i = 0; i < edit_references.length; i++) {

      let editRef = edit_references[i]; 

      let refId = editRef.id;

      var count = 0;
      var flag = 0;

      db.collection("contents").doc(refId).get().then(function(_doc) {

          var data = _doc.data();          

          let _name = data.name;  

          var _id = _doc.id;
 
          let _amount = data.amount;  
          
          let _time =  data.last_update;

          let _new =  data.new;

          let _short = data.short;                

          window.datatable_main = $('#grid-main').DataTable({
            scrollY: "180px",
            scrollCollapse: true,
            paging:         false,
            retrieve: true, 
            bInfo : false,      
            columns: [             
              { "data": "meta.id" },
              { "data": "meta.Nombre" },
              { "data": "meta.Cantidad" },
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
                "targets": [ 2 ],
                "visible": true,
                "searchable": true,
                "width": "30%"
              },
              {
                "targets": [ 3 ],
                "visible": true,
                "searchable": true,
                "width": "15%"
              },              
            ]                 
          });  

          /*
          { "data": "meta.id" },
              { "data": "meta.Nombre" },
              { "data": "meta.Cantidad" },
              { "data": "meta.Actualizado" }        */
              

          let row = { 
            "meta": {                
              "id": _id, 
              "Nombre": _name, 
              "Cantidad": _amount, 
              "Actualizado": _time,              
             } 
          };   

          window.jsonDataMain.push(row);

          $('#grid-main tbody').on('click', 'tr', function () {

              var data = window.datatable_main.row( this ).data();
              //console.log(data.meta.id);
              window._id_document_collection = data.meta.id;
              
              //alert( 'You clicked on '+data.meta.id+'\'s row' );
              if ( $(this).hasClass('selected') ) {
                  $(this).removeClass('selected');
                  $("#edit-button").prop('disabled', true);
                  clearFirepad();            
                  $("#publish-buttons").hide();
                  $("#firepad-container").hide();
              }
              else {
                window.datatable_detail.$('tr.selected').removeClass('selected');
                  $(this).addClass('selected');
                  $("#edit-button").removeAttr('disabled');
                  $("#publish-buttons").show();
                  $("#firepad-container").show();
                  loadEdits(data.meta.database_ref, _short);                        
              }
              
          });   
  
          editObjects[_id] = _doc;

          if (length == (count-1)) {    
            
            window.datatable_main.rows.add(window.jsonDataMain);
            window.datatable_main.draw();    

            homeLoader.hide();

          }       
          count++;      
      });

    }  

    $('#edit-list li').click(function() { 
      $('li.list-group-item.active').removeClass("active"); 
      $(this).addClass("active"); 
    });           
    

    window.jsonDataDetail = [];
    window.editDocuments = [];

    window._short;
    window._id_document_collection;
    window.database_ref;
  
    window.loadEditsList = function(_new, _short) { 

      window._short = _short;      
      
      clearFirepad();      

      var _doc = editObjects[_short];   
  
      _doc.ref.collection("collection").get()
      .then(function(querySnapshotEdit) {
  
           var editLength = querySnapshotEdit.docs.length;
  
           var countLines = 1;        

          if (window.datatable_detail !=undefined ) {
            window.datatable_detail.clear();            
            $('#new-button').text(_new);
          }

          window.datatable_detail = $('#grid-details').DataTable({
            scrollY: "180px",
            scrollCollapse: true,
            paging: false,
            retrieve: true, 
            bInfo : false,                                                       
            columns: [
              { "data": "meta.database_ref" },
              { "data": "meta.id" },
              { "data": "meta.Nombre" },
              { "data": "meta.Desc" },
              { "data": "meta.Actualizado" },
              { "data": "meta.Image}n" }
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
                "width": "30%"
              },
              {
                "targets": [ 4 ],
                "visible": true,
                "searchable": true,
                "width": "15%"
              },
              {
                "targets": [ 5 ],
                "visible": true,
                "searchable": false,
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

              var data = window.datatable_detail.row( this ).data();
              console.log(data.meta.id);

              window._id_document_collection = data.meta.id;
              
              //alert( 'You clicked on '+data.meta.id+'\'s row' );
              if ( $(this).hasClass('selected') ) {
                  $(this).removeClass('selected');
                  $("#edit-button").prop('disabled', true);
                  clearFirepad();            
                  $("#publish-buttons").hide();
                  $("#firepad-container").hide();
              }
              else {
                window.datatable_detail.$('tr.selected').removeClass('selected');
                  $(this).addClass('selected');
                  $("#edit-button").removeAttr('disabled');
                  $("#publish-buttons").show();
                  $("#firepad-container").show();
                  loadEdits(data.meta.database_ref, _short);                        
              }
              
          });      
          
  
          querySnapshotEdit.forEach(function(docEdit) {

            let _doc_id_ = docEdit.id;
            
            window.editDocuments[_doc_id_] = docEdit;
  
             var editData = docEdit.data();   
             
             let _date = editData.last_update;

             let last_update = getDateFrom(_date.toDate());

             if (editData.html != undefined){
               window.html = editData.html;
             }

             let _icon = editData.icon;
  
             let row = { 
               "meta": {  
                 "database_ref": editData.database_ref, 
                 "id": _doc_id_, 
                 "Nombre": editData.name, 
                 "Desc": editData.description.slice(0, 20) + "...", 
                 "Actualizado": last_update,
                 "Imagen": "<img src='" + _icon + "' style='height:30px; width:30px'>",
                } 
             };   
  
             window.jsonDataDetail.push(row);
  
             let database_ref = editData.database_ref;    
             
             if (editLength == countLines) {                                                            
                window.datatable_detail.rows.add(window.jsonDataDetail);
                window.datatable_detail.draw();    
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

        window.datatable_detail.clear();
        
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
          "id" : window._short,
          "Nombre": new_name, 
          "Desc": new_desc, 
          "Actualizado": thedate } };   

        window.jsonDataDetail.push(row); 
        
        db.collection(document_path).add( {
          
          group_ref : _user.yearReference,
          name : new_name,
          description : new_desc,
          database_ref : _database_ref,
          last_update : _time        

        }).then(function(doc){   
          
            let _id = doc.id;
          
            var storage_path = "contents/" + window._short + "/" + _id;

            var storageRef = storage.ref(storage_path);        
            var file = document.getElementById("imgInp").files[0];                 
            let rnd = Math.floor((Math.random()) * 0x10000).toString(7);                                                              
            var filePath = window._short + "_" +  rnd + ".png";            
            
            var thisRef = storageRef.child(filePath);                         

            var metadata = {
                customMetadata: {
                    'thumbnail': 'true',
                    'type' : '3',
                    'short' : window._short,
                    'id' : _id                   
                }
            }

            thisRef.put(file, metadata);

            window.datatable_detail.rows.add(window.jsonDataDetail);
            window.datatable_detail.draw(); 
              
            $('#addModal').modal('hide');

            $("#firepad-container").show();

            loadEdits(_database_ref, window._short);

            var num = parseInt($("#" + window._short).text());

            num++;

            $("#" + window._short).text(num);
            $('#addPostModal').modal('hide');  


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

     $('#button-publish').click(function() { 
        $('#publishModal').modal('show');        
      });

    $('#publishModal').on('hidden.bs.modal', function () {
      
    });

    $('#acceptCheckbox').change(function() {
      if ($(this).prop('checked')) {
        $('#button-accept').prop('disabled', false);       
      } else  {
        $('#button-accept').prop('disabled', true);
      }
    });

    $('#button-accept').click(function(event) { 

      event.preventDefault();

      var _document = window.editDocuments[window._id_document_collection];
        var _time =  new Date(); 
        db.collection('contents')
        .doc(window._short)
        .collection("collection")
        .doc(window._id_document_collection)
        .update({        
          "approved" : false,
          "published" : false,
          "last_update" : _time        
        })
        .then(function(documentUpdated) {

          $('#publishModal').modal('hide');

        })
        .catch(function(error) {
          console.error("Error adding document: ", error);
        }); 

    });

     $('#button-save').click(function() {     
      
      var settings = {
          "url": "https://us-central1-curupas-app.cloudfunctions.net/publish",
          "method": "POST",
          "timeout": 0,
          "headers": {
            "Content-Type": "application/json"
          },
          "data": JSON.stringify({
            "database_ref":window.database_ref,
            "contentType":window._short,
            "documentId":window._id_document_collection
          }),
        };

        homeLoader.show();  
        
        $.ajax(settings).done(function (response) {

          console.log(response);

          if (response.data.result) {
            homeLoader.hide();  
            //$('#view-save').prop('disabled', false);
            window.html = response.data.html;           
          } 
          
        });     
    });

    $('#view-save').click(function() { 
        $('#previewModal').modal('show');
        $('#modal-content').append("<div id='modal-container'>" + window.html + "</div>");
    });

    $('#previewModal').on('hidden.bs.modal', function () {
      $('#modal-container').remove();
    });     
     
    function loadEdits(database_ref, _short) { 

      window.database_ref = database_ref;     
      
      //$('#button-publish').prop('disabled', true);
      
      $('#button-save').prop('disabled', true);
      $('#button-accept').prop('disabled', true);      

      //$('#view-save').prop('disabled', true);

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
      
      codeMirror.on('drop', function(data, e) {
        var file;
        var files;
        // Check if files were dropped
        var _URL = window.URL || window.webkitURL;
        files = e.dataTransfer.files;
        if (files.length > 0) {
          e.preventDefault();
          e.stopPropagation();
          _file = files[0];
          //alert('File: ' + file.name);
          var img = new Image();    
          img = new Image();
          var objectUrl = _URL.createObjectURL(_file);
          img.onload = function () {

              var _width = this.width;
              var _height = this.height;
              
              var metadataFiles = {
                customMetadata: {
                    'thumbnail': 'false',
                    'type' : '0'
                }
              }              

              var storageRef = storage.ref("contents/" + _short + "/" + window._id_document_collection + "/images");       

              let rnd = Math.floor((Math.random()) * 0x10000).toString(7);
                                                              
              var filePathPost = _short + "_" +  rnd + ".png";        
              const postRef = storageRef.child(filePathPost);
              const putRef = postRef.put(_file, metadataFiles);  
              //prefArray.push(putRef);  
              putRef.on('state_changed', function(snapshot) {
                  var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                  console.log('Upload is ' + progress + '% done');
                  switch (snapshot.state) {
                    case firebase.storage.TaskState.PAUSED: // or 'paused'
                      console.log('Upload is paused');
                      break;
                    case firebase.storage.TaskState.RUNNING: // or 'running'
                      console.log('Upload is running');
                      break;
                  }
                }, function(error) {
                  // Handle unsuccessful uploads
                }, function() {                                                          
                  putRef.snapshot.ref.getDownloadURL().then(function(downloadURL) {                      
                      firepad.insertEntity('img', {
                        'src' : downloadURL,
                        'width' : _width,
                        'height' : _height
                      });
                       
                  });                  
              });             
              
          };          
          img.src = objectUrl;
          return false;
        }
      });

      //LISTENER DRAG
      //https://gist.github.com/mikelehen/fa5ceab5ad6f241b6544
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
        
        firepad.on('newLine', function() {

          $('#button-save').prop('disabled', false);        
          
        });        


        codeMirror.focus();

        codeMirror.setOption('dragDrop', true);        
       

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

      $(".firepad-tb-insert-image").parent().parent().hide();


    }     
    
    function readURL(input) {
      if (input.files && input.files[0]) {
          var reader = new FileReader();            
          reader.onload = function (e) {
              $('#avatar-preview').attr('src', e.target.result);
          }            
          reader.readAsDataURL(input.files[0]);
      }
  }
  
  $("#imgInp").change(function(){
      readURL(this);
  });

  /*Spinner*/

  function modal(){
     $('.modal').modal('show');
     setTimeout(function () {
       console.log('hejF');
       $('.modal').modal('hide');
     }, 3000);
  }
    
  //# sourceURL=textedit.js   

  });

  

   
