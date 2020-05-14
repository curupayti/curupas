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
    
        const activePanelHeight = activePanel.offsetHeight;
    
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

        if (!window._main_row_selected) {
            return;
        }    
    
        if (!(eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`) || eventTarget.classList.contains(`${DOMstrings.stepNextBtnClass}`)))
        {
        return;
        }
    
        const activePanel = findParent(eventTarget, `${DOMstrings.stepFormPanelClass}`);
    
        let activePanelNum = Array.from(DOMstrings.stepFormPanels).indexOf(activePanel);
    
        if (eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`)) {
        activePanelNum--;
    
        } else {
    
        activePanelNum++;
    
        }
    
        setActiveStep(activePanelNum);
        setActivePanel(activePanelNum);
    
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

            //let _size =  imagesSnapshot.size;

            //let item = `<tr data-id="${document.id}">
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
            // Select/Deselect checkboxes
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

        //$('#btn-seleccionar-contenido').prop('disabled', false);

        $("#btn-categorias").text(_name);
    });


    window.jsonDataDetail = [];
    window.editDocuments = [];

    window._main_row_selected = false;
    window._short;
    window._id_document_collection;
    window.database_ref;
  
    window.loadEditsList = function(_new, _short) { 

      window._short = _short;      
      
      //clearFirepad();      

      var _doc = window.editObjects[_short];   
  
      _doc.ref.collection("collection").get()
      .then(function(querySnapshotEdit) {
  
           var editLength = querySnapshotEdit.docs.length;                     
                 
          /*$('#grid-details tbody').on('click', 'tr', function () {             

              var data = window.datatable_detail.row( this ).data();
              
              console.log(data.meta.id);

              window._id_document_collection = data.meta.id;
              
              //alert( 'You clicked on '+data.meta.id+'\'s row' );
              if ( $(this).hasClass('selected') ) {
                  $(this).removeClass('selected');
                  $("#edit-button").prop('disabled', true);
                  clearFirepad();            
                  $("#publish-buttons").hide();
                  //$("#firepad-container").hide();
              }
              else {
                window.datatable_detail.$('tr.selected').removeClass('selected');
                  $(this).addClass('selected');
                  $("#edit-button").removeAttr('disabled');
                  $("#publish-buttons").show();
                  
                  $("#firepad-container").show();                  
                  
                  $('#editModal').modal('show');

                  $('#editModal').on('shown.bs.modal', function () {                       
                    var height = $(document).height();
                    $("#body-modal").css({'height': height + 'px'});
                    setTimeout( function() {                          
                        loadEdits(data.meta.database_ref, _short);   
                    }, 500);
                 });
              }

              $('#editModal').modal('show');
              
          });*/      
          

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
                
                //$("#detail-table").find("tr:gt(0)").remove();     

                $("#btn-contenidos").text(_name);

                setTimeout( function() {                          
                    loadEdits(database_ref, _short);   
                }, 500);                
              
              //alert( 'You clicked on '+data.meta.id+'\'s row' );
              /*if ( $(this).hasClass('selected') ) {
                  $(this).removeClass('selected');
                  $("#edit-button").prop('disabled', true);
                  clearFirepad();            
                  $("#publish-buttons").hide();
                  //$("#firepad-container").hide();
              }
              else {
                window.datatable_detail.$('tr.selected').removeClass('selected');
                  $(this).addClass('selected');
                  $("#edit-button").removeAttr('disabled');
                  $("#publish-buttons").show();
                  
                  $("#firepad-container").show();                  
                  
                  $('#editModal').modal('show');

                  $('#editModal').on('shown.bs.modal', function () {                       
                    var height = $(document).height();
                    $("#body-modal").css({'height': height + 'px'});
                    setTimeout( function() {                          
                        loadEdits(data.meta.database_ref, _short);   
                    }, 500);
                 });
              }

              $('#editModal').modal('show');*/              

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

    // ADD EMPLOYEE
    $("#add-post-form").submit(function (event) {
        event.preventDefault();       

        var title = $('#post-title').val();
        
        var description = $('#description').val();

        var storageRef = storage.ref("/posts");        
        var file = document.getElementById("imgInp").files[0];       
        var filePath =  title + ".png";        
        var thisRef = storageRef.child(filePath);          
        
        var postId;       
        
        $('.lds-dual-ring').css('visibility', 'visible');

        db.collection("posts").add({
            title: title,
            description: description,
            //author: user.email
        })
        .then(function(docRef) {
            postId = docRef.id;            
            var metadata = {
                customMetadata: {
                    'thumbnail': 'true',
                    'type' : '1',
                    'id' : postId,
                    'collection' : 'posts'                   
                }
            }
            return thisRef.put(file, metadata);                    
        })       
        .then(function(snapshot) {                                    
            var metadataFiles = {
                customMetadata: {
                    'thumbnail': 'false',
                    'type' : '0'
                }
            }
            var prefArray = [];
            var input = document.getElementById("proImage");
            var j=0, k=0;
            var length = input.files.length;

            for (var i = 0; i < length; ++i) {            
                var _file = input.files.item(i);                                                  
                var filePathPost = title + "_" + i + "_original.png";        
                const postRef = storageRef.child(filePathPost);
                const putRef = postRef.put(_file, metadataFiles);  
                prefArray.push(putRef);  
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
                    var putRefFromArray = prefArray[j];
                    putRefFromArray.snapshot.ref.getDownloadURL().then(function(downloadURL) {                      
                        db.collection("posts").doc(postId).collection("images").add({downloadURL});
                        if (k==(length-1)){
                            $('#addPostModal').modal('hide');
                        }
                        k++;
                    });
                    j++;
                });   
            }
            console.log("termino");
        })        
        .catch(function(error) {
            console.error("Error adding document: ", error);
        });   
    });

    // DELETE POST
    $(document).on('click', '.js-delete-post', function () {
        let id = $(this).attr('id');
        $('#delete-post-form').attr('delete-id', id);
        $('#deletePostModal').modal('show');
    });

    $("#delete-post-form").submit(function (event) {
        event.preventDefault();
        let id = $(this).attr('delete-id');        
        deleteAllImagesOnPost(id);
        if (id != undefined) {            
            let _path = "posts/" + id;
            deleteDocumentAtPath(_path);
        } else {
            let checkbox = $('table tbody input:checked');
            checkbox.each(function () {
                let _path = "posts/" + this.value;
                deleteDocumentAtPath(_path);               
            });
            $("#deletePostModal").modal('hide');
        }
    });

    function deleteAllImagesOnPost(id){        
        //Delete Thumbnail
        
        //let _SelectedDocument = _documents[id];
        //deleteImageByUrl(_SelectedDocument.data().thumbnailSmallUrl);
        
        let _images = _imageSnapshot[id];

        _images.docs.forEach(doc => {
            //doc.data()
            let _url = doc.data().downloadURL;
            deleteImageByUrl(_url);

        });          
    }

    function deleteImageByUrl(url) {
        // Create a reference to the file to delete
        var desertRef = firebase.storage().refFromURL("gs://" + url);
        // Delete the file
        desertRef.delete().then(function() {
        // File deleted successfully
        }).catch(function(error) {
        // Uh-oh, an error occurred!
        });
    }

    function deleteDocumentAtPath(path) {
        var deleteFn = firebase.functions().httpsCallable('recursiveDelete');
        deleteFn({ path: path })
            .then(function(result) {
                console.log('Delete success: ' + JSON.stringify(result));
                $("#deletePostModal").modal('hide');
            })
            .catch(function(err) {
                console.log('Delete failed, see console,');
                console.warn(err);
            });
    }
    

    // UPDATE EMPLOYEE
    $(document).on('click', '.js-edit-post', function () {
        let id = $(this).attr('id');
        $('#edit-employee-form').attr('edit-id', id);
        db.collection('employees').doc(id).get().then(function (document) {
            if (document.exists) {
                $('#edit-employee-form #employee-name').val(document.data().name);
                $('#edit-employee-form #employee-email').val(document.data().email);
                $('#edit-employee-form #employee-address').val(document.data().address);
                $('#edit-employee-form #employee-phone').val(document.data().phone);
                $('#editEmployeeModal').modal('show');
            } else {
                console.log("No such document!");
            }
        }).catch(function (error) {
            console.log("Error getting document:", error);
        });
    });

    $("#edit-employee-form").submit(function (event) {
        event.preventDefault();
        let id = $(this).attr('edit-id');
        db.collection('employees').doc(id).update({
            name: $('#edit-employee-form #employee-name').val(),
            email: $('#edit-employee-form #employee-email').val(),
            address: $('#edit-employee-form #employee-address').val(),
            phone: $('#edit-employee-form  #employee-phone').val()
        });
        $('#editEmployeeModal').modal('hide');
    });

    $("#addPostModal").on('hidden.bs.modal', function () {
        $('#add-post-form .form-control').val('');
    });

    $("#editEmployeeModal").on('hidden.bs.modal', function () {
        $('#edit-employee-form .form-control').val('');
    });

    // PAGINATION
    $("#js-previous").on('click', function () {
        $('#main-table tbody').html('');
        var previous = db.collection("employees")
            .orderBy(firebase.firestore.FieldPath.documentId(), "desc")
            .startAt(firstVisible)
            .limit(3);
        previous.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderPost(doc);
            });
        });
    });

    $('#js-next').on('click', function () {
        if ($(this).closest('.page-item').hasClass('disabled')) {
            return false;
        }
        $('#main-table tbody').html('');
        var next = db.collection("employees")
            .startAfter(lastVisible)
            .limit(3);
        next.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderPost(doc);
            });
            lastVisible = documentSnapshots.docs[documentSnapshots.docs.length - 1];
            firstVisible = documentSnapshots.docs[documentSnapshots.docs.length - 1];
            let nextChecker = documentSnapshots.docs.length - 1;
            if (nextChecker == 0) {
                $('#js-next').closest('.page-item').addClass('disabled');
            }
        });
    });

    //--
    //-- Image Picker
    //--   

    /*document.getElementById('proImage').addEventListener('change', readImage, false);        
    
    $(document).on('click', '.image-cancel', function() {
        let no = $(this).data('no');
        $(".preview-image.preview-show-"+no).remove();
    });*/
    
    var num = 4;
    function readImage() {
        if (window.File && window.FileList && window.FileReader) {
            var files = event.target.files; //FileList object
            //$( ".preview-images-zone" ).sortable();
            var output = $(".preview-images-zone");    
            for (let i = 0; i < files.length; i++) {
                var file = files[i];
                if (!file.type.match('image')) continue;                
                var picReader = new FileReader();                
                picReader.addEventListener('load', function (event) {
                    var picFile = event.target;
                    var html =  '<div class="preview-image preview-show-' + num + '">' +
                                '<div class="image-cancel" data-no="' + num + '">x</div>' +
                                '<div class="image-zone"><img id="pro-img-' + num + '" src="' + picFile.result + '"></div>' +
                                '<div class="tools-edit-image"><a href="javascript:void(0)" data-no="' + num + '" class="btn btn-light btn-edit-image">edit</a></div>' +
                                '</div>';
    
                    output.append(html);
                    num = num + 1;
                });
    
                picReader.readAsDataURL(file);
            }
            $("#pro-image").val('');
        } else {
            console.log('Browser not support');
        }
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

