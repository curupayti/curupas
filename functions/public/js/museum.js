$(document).ready(function () {

    let _documents = {};
    let _imageSnapshot = {};
    
    let deleteIDs = [];
    let lastVisible;
    let firstVisible;

    // REAL TIME LISTENER
    db.collection('museums').onSnapshot(snapshot => {
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
                renderMuseum(change.doc);
            } else if (change.type == 'modified') {
                $('tr[data-id=' + change.doc.id + ']').remove();
                renderMuseum(change.doc);
            } else if (change.type == 'removed') {
                $('tr[data-id=' + change.doc.id + ']').remove();
            }
        });
    });

    function renderMuseum(document) {  
        _documents[document.id] = document;      
        let _time = formatDate(Date(document.data().timeStamp));        
        document.ref.collection("images").get().then(function(imagesSnapshot) {
            _imageSnapshot[document.id] = imagesSnapshot;
            let _size =  imagesSnapshot.size;
            let item = `<tr data-id="${document.id}">
            <td>
                <span class="custom-checkbox">
                    <input type="checkbox" id="${document.id}" name="options[]" value="${document.id}">
                    <label for="${document.id}"></label>
                </span>
            </td>
            <td>${document.data().title}</td>
            <td>${document.data().description}</td>
            <td>
                <img id="image_${document.id}" class="avatar-preview-list" src="${document.data().thumbnailSmallUrl}" alt="your image" />            
            </td>
            <td>${_time}</td>  
            <td><a href="#" id="${document.id}" class="js-view-images">${_size}</a></td>        
            <td>
                <a href="#" id="${document.id}" class="edit js-edit-museum"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
                </a>
                <a href="#" id="${document.id}" class="delete js-delete-museum"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
                </a>
            </td>
            </tr>`;
            $('#museum-table').append(item);            
            // Select/Deselect checkboxes
            var checkbox = $('table tbody input[type="checkbox"]');
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
        });        
    }

    // VIEW IMAGES
    $(document).on('click', '.js-view-images', function () {
       
    });

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

    // ADD EMPLOYEE
    $("#add-museum-form").submit(function (event) {
        event.preventDefault();       

        var title = $('#museum-title').val();
        
        var description = $('#description').val();

        var storageRef = storage.ref("/museums");        
        var file = document.getElementById("imgInp").files[0];       
        var filePath =  title + ".png";        
        var thisRef = storageRef.child(filePath);          
        
        var museumId;       
        
        $('.lds-dual-ring').css('visibility', 'visible');

        db.collection("museums").add({
            title: title,
            description: description,
            //author: user.email
        })
        .then(function(docRef) {
            museumId = docRef.id;            
            var metadata = {
                customMetadata: {
                    'thumbnail': 'true',
                    'type' : '1',
                    'museumId' : museumId                   
                }
            }
            return thisRef.put(file, metadata);                    
        })       
        .then(function(snapshot) {                                    
            var metadataFiles = {
                customMetadata: {
                    'thumbnail': 'false'
                    //'type' : '2',
                    //'museumId' : museumId                   
                }
            }
            var prefArray = [];
            var input = document.getElementById("proImage");
            var j=0, k=0;
            var length = input.files.length;
            for (var i = 0; i < length; ++i) {            
                var _file = input.files.item(i);                                                  
                var filePathMuseum = title + "_" + i + "_original.png";        
                const museumRef = storageRef.child(filePathMuseum);
                const putRef = museumRef.put(_file, metadataFiles);  
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
                        db.collection("museums").doc(museumId).collection("images").add({downloadURL});
                        if (k==(length-1)){
                            $('#addMuseumModal').modal('hide');
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
    $(document).on('click', '.js-delete-museum', function () {
        let id = $(this).attr('id');
        $('#delete-museum-form').attr('delete-id', id);
        $('#deleteMuseumModal').modal('show');
    });

    $("#delete-museum-form").submit(function (event) {
        event.preventDefault();
        let id = $(this).attr('delete-id');        
        deleteAllImagesOnMuseum(id);
        if (id != undefined) {            
            let _path = "museums/" + id;
            deleteDocumentAtPath(_path);
        } else {
            let checkbox = $('table tbody input:checked');
            checkbox.each(function () {
                let _path = "museums/" + this.value;
                deleteDocumentAtPath(_path);               
            });
            $("#deleteMuseumModal").modal('hide');
        }
    });

    function deleteAllImagesOnMuseum(id){        
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
                $("#deleteMuseumModal").modal('hide');
            })
            .catch(function(err) {
                console.log('Delete failed, see console,');
                console.warn(err);
            });
    }
    

    // UPDATE EMPLOYEE
    $(document).on('click', '.js-edit-museum', function () {
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

    $("#addMuseumModal").on('hidden.bs.modal', function () {
        $('#add-museum-form .form-control').val('');
    });

    $("#editEmployeeModal").on('hidden.bs.modal', function () {
        $('#edit-employee-form .form-control').val('');
    });

    // PAGINATION
    $("#js-previous").on('click', function () {
        $('#museum-table tbody').html('');
        var previous = db.collection("employees")
            .orderBy(firebase.firestore.FieldPath.documentId(), "desc")
            .startAt(firstVisible)
            .limit(3);
        previous.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderMuseum(doc);
            });
        });
    });

    $('#js-next').on('click', function () {
        if ($(this).closest('.page-item').hasClass('disabled')) {
            return false;
        }
        $('#museum-table tbody').html('');
        var next = db.collection("employees")
            .startAfter(lastVisible)
            .limit(3);
        next.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderMuseum(doc);
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

    document.getElementById('proImage').addEventListener('change', readImage, false);        
    
    $(document).on('click', '.image-cancel', function() {
        let no = $(this).data('no');
        $(".preview-image.preview-show-"+no).remove();
    });    
    
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


    //# sourceURL=museum.js 

});

(function ($) {
    "use strict";
    function centerModal() {
        $(this).css('display', 'block');
        var $dialog = $(this).find(".modal-dialog"),
            offset = ($(window).height() - $dialog.height()) / 2,
            bottomMargin = parseInt($dialog.css('marginBottom'), 10);

        // Make sure you don't hide the top part of the modal w/ a negative margin if it's longer than the screen height, and keep the margin equal to the bottom margin of the modal
        if (offset < bottomMargin) offset = bottomMargin;
        $dialog.css("margin-top", offset);
    }

    $(document).on('show.bs.modal', '.modal', centerModal);
    $(window).on("resize", function () {
        $('.modal:visible').each(centerModal);
    });
    
}(jQuery));