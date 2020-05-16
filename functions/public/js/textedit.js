$(document).ready(function () {

    //https://webdevtrick.com/bootstrap-multi-step-form-animations/
    
    const DOMstrings = {
        stepsBtnClass: 'multisteps-form__progress-btn',
        stepsBtns: document.querySelectorAll(`.multisteps-form__progress-btn`),
        stepsBar: document.querySelector('.multisteps-form__progress'),
        stepsForm: document.querySelector('.multisteps-form__form'),
        stepsFormTextareas: document.querySelectorAll('.multisteps-form__textarea'),
        stepFormPanelClass: 'multisteps-form__panel',
        stepFormPanels: document.querySelectorAll('.multisteps-form__panel'),
        stepPrevBtnClass: 'js-btn-prev',
        stepNextBtnClass: 'js-btn-next' };

    window.activePanelNum = 0;
    
    
    const removeClasses = (elemSet, className) => {
    
        elemSet.forEach(elem => {
    
        elem.classList.remove(className);
    
        });
    
    };
    
    const findParent = (elem, parentClass) => {
    
        let currentNode = elem;
    
        while (!currentNode.classList.contains(parentClass)) {
        currentNode = currentNode.parentNode;
        }
    
        return currentNode;
    
    };
    
    const getActiveStep = elem => {
        return Array.from(DOMstrings.stepsBtns).indexOf(elem);
    };
    
    const setActiveStep = activeStepNum => {

    
        removeClasses(DOMstrings.stepsBtns, 'js-active');
    
        DOMstrings.stepsBtns.forEach((elem, index) => {
    
        if (index <= activeStepNum) {
            elem.classList.add('js-active');
        }
    
        });
    };
    
    const getActivePanel = () => {
    
        let activePanel;
    
        DOMstrings.stepFormPanels.forEach(elem => {
    
        if (elem.classList.contains('js-active')) {
    
            activePanel = elem;
    
        }
    
        });
    
        return activePanel;
    
    };
    
    const setActivePanel = activePanelNum => {
    
        removeClasses(DOMstrings.stepFormPanels, 'js-active');
    
        DOMstrings.stepFormPanels.forEach((elem, index) => {
        if (index === activePanelNum) {
    
            elem.classList.add('js-active');
    
            setFormHeight(elem);
    
        }
        });
    
    };
    
    const formHeight = activePanel => {
    
        var activePanelHeight = activePanel.offsetHeight;        

        if (window.activePanelNum==2) {

            $("#columna").removeClass("col-lg-8");                        

            //$('#firepadform').height(1500);            

        } else {
            $("#columna").addClass("col-lg-8");
        }
    
        DOMstrings.stepsForm.style.height = `${activePanelHeight}px`;        
    
    };
    
    const setFormHeight = () => {
        const activePanel = getActivePanel();
    
        formHeight(activePanel);
    };
    
    DOMstrings.stepsBar.addEventListener('click', e => {
    
        const eventTarget = e.target;
    
        if (!eventTarget.classList.contains(`${DOMstrings.stepsBtnClass}`)) {
        return;
        }        
    
        const activeStep = getActiveStep(eventTarget);
    
        setActiveStep(activeStep);
    
        setActivePanel(activeStep);
    });
    
    DOMstrings.stepsForm.addEventListener('click', e => {  
    
        const eventTarget = e.target;

        if (!window._main_row_selected && window.activePanelNum==0) {
            return;
        }    

        if (!window._detail_row_selected && window.activePanelNum==1) {
          return;
        }     
    
        if (!(eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`) || eventTarget.classList.contains(`${DOMstrings.stepNextBtnClass}`)))
        {
        return;
        }
    
        const activePanel = findParent(eventTarget, `${DOMstrings.stepFormPanelClass}`);
    
        window.activePanelNum = Array.from(DOMstrings.stepFormPanels).indexOf(activePanel);
    
        if (eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`)) {
            window.activePanelNum--;
    
        } else {
    
        window.activePanelNum++;
    
        }
    
        setActiveStep(window.activePanelNum);
        setActivePanel(window.activePanelNum);
    
    });    
    
    //window.addEventListener('load', setFormHeight, false);    
    //window.addEventListener('resize', setFormHeight, false);    
    
    const setAnimationType = newType => {
        DOMstrings.stepFormPanels.forEach(elem => {
        elem.dataset.animation = newType;
        });
    };       

    let _documents = {};
    let _imageSnapshot = {};
    
    let deleteIDs = [];
    let lastVisible;
    let firstVisible;

    window.editDocuments = [];

    window._short;
    window._id_document_collection;
    window.database_ref;

    window.editObjects;    

    // REAL TIME LISTENER
    db.collection('contents').onSnapshot(snapshot => {
        let size = snapshot.size;
        $('.count').text(size);
        if (size == 0) {
            $('#selectAll').attr('disabled', true);
        } else {
            $('#selectAll').attr('disabled', false);
        }      

        let changes = snapshot.docChanges();
        changes.forEach(change => {
            if (change.type == 'added') {
                renderPost(change.doc);
            } else if (change.type == 'modified') {
                $('tr[data-id=' + change.doc.id + ']').remove();
                renderPost(change.doc);
            } else if (change.type == 'removed') {
                $('tr[data-id=' + change.doc.id + ']').remove();
            }
        });
    });

    function renderPost(document) { 

        window.editObjects[document.data().short] = document;      

        let _time = formatDate(Date(document.data().timeStamp));  
        let _last_update = formatDate(Date(document.data().last_update));        

        document.ref.collection("images").get().then(function(imagesSnapshot) {
            
            _imageSnapshot[document.id] = imagesSnapshot;
        
            let item = `<tr class="clickable-row-main" 
                data-id="${document.id}" 
                data-new="${document.data().new}" 
                data-name="${document.data().name}" 
                data-short="${document.data().short}">                
            <td>
                <span class="custom-checkbox">
                    <input type="checkbox" id="${document.id}" name="options[]" value="${document.id}">
                    <label for="${document.id}"></label>
                </span>
            </td>
            <td>${document.data().amount}</td>                 
            <td>${document.data().name}</td>                              
            <td>${document.data().desc}</td>  
            <td>
                <a href="#" id="${document.id}" class="edit js-edit-post"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
                </a>
                <a href="#" id="${document.id}" class="delete js-delete-post"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
                </a>
            </td>
            <td>${_last_update}</td>                          
            </tr>`;
            $('#main-table').append(item);            

            let checkbox = $('#main-table tbody input[type="checkbox"]');

            $("#selectAllMain").click(function () {
                if (this.checked) {
                    checkbox.each(function () {
                        console.log(this.id);
                        deleteIDs.push(this.id);
                        this.checked = true;
                    });
                } else {
                    checkbox.each(function () {
                        this.checked = false;
                    });
                }
            });
            checkbox.click(function () {
                if (!this.checked) {
                    $("#selectAllMain").prop("checked", false);
                }
            });

            $("#btn-categorias").click();

        });    
        
        
    }

    // VIEW IMAGES
    $(document).on('click', '.clickable-row-main', function (event) {       

        let dataid = $(this).data("id");
        let _new = $(this).data("new");
        let _short = $(this).data("short");
        let _name = $(this).data("name");

        window._id_document_collection = dataid;     

        var checkboxes = $('#main-table tbody input[type="checkbox"]');

        checkboxes.each(function () {
            this.checked = false;
        });

        $(this).find('input[type="checkbox"]').prop("checked", true);                 
        
        $("#detail-table").find("tr:gt(0)").remove();               
        
        loadEditsList(_new, _short);   
        
        $("#detail-grid").show();

        window._main_row_selected = true;        

        $("#btn-categorias").text(_name);

        
        $("#firepad-container").css("left", 0);
        $("#firepad-container").css("height", 570);

        $("#firepadform").css("height", 650);
        $("#firepaditem").css("height", 570);               
        
    });

    window.jsonDataDetail = [];
    window.editDocuments = [];

    window._main_row_selected = false;
    window._detail_row_selected = false;

    window._short;
    window._id_document_collection;
    window.database_ref;
  
    window.loadEditsList = function(_new, _short) { 

      window._short = _short;      
      
      clearFirepad();      

      var _doc = window.editObjects[_short];   
  
      _doc.ref.collection("collection").get()
      .then(function(querySnapshotEdit) {
  
          var editLength = querySnapshotEdit.docs.length;                     

          var _count = 0;

          var _length = querySnapshotEdit.size;
  
          querySnapshotEdit.forEach(function(docEdit) {

            var editData = docEdit.data();
              
            window._id_document_collection = editData.id;  
            
            //let _new = editData.new;
            //let _short = editData.short;          
            
            let _doc_id_ = docEdit.id;
            
            window.editDocuments[_doc_id_] = docEdit;          
             
            let _date = editData.last_update;

            let last_update = getDateFrom(_date.toDate());

             if (editData.html != undefined){
               window.html = editData.html;
             }

             let _icon = editData.icon;

            //let item = `<tr data-id="${document.id}">
            let item = `<tr class="clickable-row-detail" 
            data-ref="${editData.database_ref}" 
            data-short="${_short}" 
            data-name="${editData.name}"             
            data-id="${_doc_id_}">
            <td>
                <span class="custom-checkbox">
                    <input type="checkbox" id="${_doc_id_}" name="options[]" value="${_doc_id_}">
                    <label for="${document.id}"></label>
                </span>
            </td>                      
            <td>${editData.name}</td>                                            
            <td>
                <img id="image_${_doc_id_}" class="avatar-preview-list" src="${_icon}" alt="your image" />            
            </td>
            <td>
                <a href="#" id="${_doc_id_}" class="edit js-edit-post"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
                </a>
                <a href="#" id="${_doc_id_}" class="delete js-delete-post"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
                </a>
            </td>
            <td>${last_update}</td>                          
            </tr>`;
            $('#detail-table').append(item);            
            
            // Select/Deselect checkboxes
            let checkbox = $('table tbody input[type="checkbox"]');
            $("#selectAll").click(function () {
                if (this.checked) {
                    checkbox.each(function () {
                        console.log(this.id);
                        deleteIDs.push(this.id);
                        this.checked = true;
                    });
                } else {
                    checkbox.each(function () {
                        this.checked = false;
                    });
                }
            });
            checkbox.click(function () {
                if (!this.checked) {
                    $("#selectAll").prop("checked", false);
                }
            });


            //HABILITAR CUANDO ANDE 
            //if (_count == (_length-1)) {
                //$("#btn-contenidos").click();                               
            //}
            //_count++;         


              // VIEW IMAGES
            $(document).on('click', '.clickable-row-detail', function (event) {    
              
                window._detail_row_selected = true; 

                let docid = $(this).data("id");
                let database_ref = $(this).data("ref");
                let _short = $(this).data("short"); 
                let _name = $(this).data("name");               

                window._id_document_collection = docid;

                var checkboxes = $('#detail-table tbody input[type="checkbox"]');

                checkboxes.each(function () {
                    this.checked = false;
                });

                $(this).find('input[type="checkbox"]').prop("checked", true);                               
            

                $("#btn-contenidos").text(_name);

                setTimeout( function() {                          
                    loadEdits(database_ref, _short);   
                }, 500);                                 

            });

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

       function formatDate(date) {
            var d = new Date(date),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();
        
            if (month.length < 2) 
                month = '0' + month;
            if (day.length < 2) 
                day = '0' + day;
        
            return [day, month, year].join('-');
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
  
              //$("#firepad-container").show();
  
              loadEdits(_database_ref, window._short);
  
              var num = parseInt($("#" + window._short).text());
  
              num++;
  
              $("#" + window._short).text(num);

              $('#mainModal').modal('hide');  
  
  
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
            //$('#button-save').prop('disabled', false);                    
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



































