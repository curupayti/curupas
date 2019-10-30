$(document).ready(function () {
    let deleteIDs = [];
    let lastVisible;
    let firstVisible;
    // REAL TIME LISTENER
    db.collection('employees').onSnapshot(snapshot => {
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
                renderEmployee(change.doc);
            } else if (change.type == 'modified') {
                $('tr[data-id=' + change.doc.id + ']').remove();
                renderEmployee(change.doc);
            } else if (change.type == 'removed') {
                $('tr[data-id=' + change.doc.id + ']').remove();
            }
        });
    });

    // db.collection('employees').startAt("abc").endAt("abc\uf8ff").get()
    // .then(function (documentSnapshots) {
    //     documentSnapshots.docs.forEach(doc => {
    //         renderEmployee(doc);
    //     });
    // });

    // db.collection('employees').startAt('bos').endAt('bos\uf8ff').on("value", function(snapshot) {
    //     console.log(snapshot);
    // });
    // var first = db.collection("employees")
    //     .limit(3);

    // first.get().then(function (documentSnapshots) {
    //     documentSnapshots.docs.forEach(doc => {
    //         renderEmployee(doc);
    //     });
    //     lastVisible = documentSnapshots.docs[documentSnapshots.docs.length - 1];
    //     console.log(documentSnapshots.docs.length - 1);
    // });


    function renderEmployee(document) {
        let item = `<tr data-id="${document.id}">
        <td>
            <span class="custom-checkbox">
                <input type="checkbox" id="${document.id}" name="options[]" value="${document.id}">
                <label for="${document.id}"></label>
            </span>
        </td>
        <td>${document.data().name}</td>
        <td>${document.data().email}</td>
        <td>${document.data().address}</td>
        <td>${document.data().phone}</td>
        <td>
            <a href="#" id="${document.id}" class="edit js-edit-employee"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
            </a>
            <a href="#" id="${document.id}" class="delete js-delete-employee"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
            </a>
        </td>
    </tr>`;
        $('#employee-table').append(item);
        // Activate tooltip
        $('[data-toggle="tooltip"]').tooltip();
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
    }

    // ADD EMPLOYEE
    $("#add-employee-form").submit(function (event) {
        event.preventDefault();
        //modal();
        var title = $('#title').val();
        var description = $('#description').val();

        var storageRef = storage.ref("/posts");        
        var file = document.getElementById("imgInp").files[0];       
        var filePath =  title + ".png";        
        var thisRef = storageRef.child(filePath);          
        
        var downloadURL, postId;

        db.collection("posts").add({
            title: title,
            description: description
        })
        .then(function(docRef) {
            postId = docRef.id;            
            var metadata = {
                customMetadata: {
                    'thumbnail': 'true',
                    'type' : '1',
                    'postId' : postId                   
                }
            }
            return thisRef.put(file, metadata);                    
        })       
        .then(function(snapshot) {            
            //downloadURL = snapshot.downloadURL;
            //return thisRef.put(file);            
            /*var files = document.getElementById("imgInp").files;
            for(var i=0; i<files.length; i++) {
                var _file = files[i];                
                var filePath =  title + ".png";        
                var thisRef = storageRef.child(filePath);
            }*/
        })        
        .catch(function(error) {
            console.error("Error adding document: ", error);
        });
        
       
       
       
      

       /* uploadThumbnail(title, function(downloadURL) {

            var files = document.getElementById("imgInp").files;       
            
        });*/
        
        /*event.preventDefault();
        db.collection('employees').add({
                name: $('#employee-name').val(),
                email: $('#employee-email').val(),
                address: $('#employee-address').val(),
                phone: $('#employee-phone').val()
            }).then(function () {
                console.log("Document successfully written!");
                $("#addEmployeeModal").modal('hide');
            })
            .catch(function (error) {
                console.error("Error writing document: ", error);
            });*/
    });


    // DELETE EMPLOYEE
    $(document).on('click', '.js-delete-employee', function () {
        let id = $(this).attr('id');
        $('#delete-employee-form').attr('delete-id', id);
        $('#deleteEmployeeModal').modal('show');
    });

    $("#delete-employee-form").submit(function (event) {
        event.preventDefault();
        let id = $(this).attr('delete-id');
        if (id != undefined) {
            db.collection('employees').doc(id).delete()
                .then(function () {
                    console.log("Document successfully delete!");
                    $("#deleteEmployeeModal").modal('hide');
                })
                .catch(function (error) {
                    console.error("Error deleting document: ", error);
                });
        } else {
            let checkbox = $('table tbody input:checked');
            checkbox.each(function () {
                db.collection('employees').doc(this.value).delete()
                    .then(function () {
                        console.log("Document successfully delete!");
                    })
                    .catch(function (error) {
                        console.error("Error deleting document: ", error);
                    });
            });
            $("#deleteEmployeeModal").modal('hide');
        }
    });

    // UPDATE EMPLOYEE
    $(document).on('click', '.js-edit-employee', function () {
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

    $("#addEmployeeModal").on('hidden.bs.modal', function () {
        $('#add-employee-form .form-control').val('');
    });

    $("#editEmployeeModal").on('hidden.bs.modal', function () {
        $('#edit-employee-form .form-control').val('');
    });

    // PAGINATION
    $("#js-previous").on('click', function () {
        $('#employee-table tbody').html('');
        var previous = db.collection("employees")
            .orderBy(firebase.firestore.FieldPath.documentId(), "desc")
            .startAt(firstVisible)
            .limit(3);
        previous.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderEmployee(doc);
            });
        });
    });

    $('#js-next').on('click', function () {
        if ($(this).closest('.page-item').hasClass('disabled')) {
            return false;
        }
        $('#employee-table tbody').html('');
        var next = db.collection("employees")
            .startAfter(lastVisible)
            .limit(3);
        next.get().then(function (documentSnapshots) {
            documentSnapshots.docs.forEach(doc => {
                renderEmployee(doc);
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

    document.getElementById('pro-image').addEventListener('change', readImage, false);        
    
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
       	console.log('hejsan');
       	$('.modal').modal('hide');
       }, 3000);
    }
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