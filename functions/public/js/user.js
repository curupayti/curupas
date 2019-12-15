    $(document).ready(function () {

        let _documents = {};
        let _imageSnapshot = {};
        
        let deleteIDs = [];
        let lastVisible;
        let firstVisible;

        var contLoded = 0;
        var size = 0;

        // REAL TIME LISTENER
        db.collection('users').onSnapshot(snapshot => {
            size = snapshot.size -1;
            $('.count').text(size);
            if (size == 0) {
                $('#selectAll').attr('disabled', true);
            } else {
                $('#selectAll').attr('disabled', false);
            }
            let changes = snapshot.docChanges();
            changes.forEach(change => {
                if (change.type == 'added') {
                    if (change.doc.id != "init") {
                        renderUser(change.doc);
                    }                
                } else if (change.type == 'modified') {
                    $('tr[data-id=' + change.doc.id + ']').remove();
                    renderUser(change.doc);
                } else if (change.type == 'removed') {
                    $('tr[data-id=' + change.doc.id + ']').remove();
                }
            });
        }); 

        function renderUser(document) {  
            _documents[document.id] = document;      

            let itemObj = {
                avatar: document.data().thumbnailPictureURL,
                id:document.id,
                name:document.data().name,
                year: document.data().year, 
                phone: document.data().phone
            };

            let item = `<tbody onclick="rowClick('` 
                + itemObj.id + `','`     
                + itemObj.avatar + `','`               
                + itemObj.name + `','` 
                + itemObj.year + `','` 
                + itemObj.phone + `');"><tr data-id="${itemObj.id}">
            <td>
                <span class="custom-checkbox">
                    <input type="checkbox" id="${itemObj.id}" name="options[]" value="${itemObj.id}">
                    <label for="${itemObj.id}"></label>
                </span>
            </td>
            <td>
                <img id="image_${itemObj.id}" class="rounded-circle avatar-preview-list" width="40" height="40" src="${itemObj.avatar}" alt="your image" />            
            </td>
            <td>${itemObj.name}</td>
            <td>${itemObj.year}</td>       
            <td>${itemObj.phone}</td>
            </tr></tbody>`;        
            $('#user-table').append(item);                   
            
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

            if (contLoded==(size-1)) {
                homeLoader.hide();
            }
            contLoded++;
        }          
        
        // VIEW IMAGES
        $(document).on('click', '.js-view-images', function () {
            alert('clicked!');
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
        $("#add-user-form").submit(function (event) {
            event.preventDefault();       
            var title = $('#title').val();
            var description = $('#description').val();

            var storageRef = storage.ref("/users");        
            var file = document.getElementById("imgInp").files[0];       
            var filePath =  title + ".png";        
            var thisRef = storageRef.child(filePath);          
            
            var userId;       
            
            $('.lds-dual-ring').css('visibility', 'visible');

            db.collection("users").add({
                title: title,
                description: description,
                //author: user.email
            })
            .then(function(docRef) {
                userId = docRef.id;            
                var metadata = {
                    customMetadata: {
                        'thumbnail': 'true',
                        'type' : '1',
                        'userId' : userId                   
                    }
                }
                return thisRef.put(file, metadata);                    
            })       
            .then(function(snapshot) {                                    
                var metadataFiles = {
                    customMetadata: {
                        'thumbnail': 'false'
                        //'type' : '2',
                        //'userId' : userId                   
                    }
                }
                var prefArray = [];
                var input = document.getElementById("proImage");
                var j=0, k=0;
                var length = input.files.length;
                for (var i = 0; i < length; ++i) {            
                    var _file = input.files.item(i);                                                  
                    var filePathUser = title + "_" + i + "_original.png";        
                    const userRef = storageRef.child(filePathUser);
                    const putRef = userRef.put(_file, metadataFiles);  
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
                            db.collection("users").doc(userId).collection("images").add({downloadURL});
                            if (k==(length-1)){
                                $('#addUserModal').modal('hide');
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

        $("#edit-user-form").submit(function (event) {
            event.preventDefault();
            let id = $(this).attr('edit-id');
            db.collection('employees').doc(id).update({
                name: $('#edit-user-form #employee-name').val(),
                email: $('#edit-user-form #employee-email').val(),
                address: $('#edit-user-form #employee-address').val(),
                phone: $('#edit-user-form  #employee-phone').val()
            });
            $('#editUserModal').modal('hide');
        });

        $("#addUserModal").on('hidden.bs.modal', function () {
            $('#add-user-form .form-control').val('');
        });

        $("#editUserModal").on('hidden.bs.modal', function () {
            $('#edit-user-form .form-control').val('');
        });

        // PAGINATION
        $("#js-previous").on('click', function () {
            $('#user-table tbody').html('');
            var previous = db.collection("employees")
                .orderBy(firebase.firestore.FieldPath.documentId(), "desc")
                .startAt(firstVisible)
                .limit(3);
            previous.get().then(function (documentSnapshots) {
                documentSnapshots.docs.forEach(doc => {
                    renderUser(doc);
                });
            });
        });

        $('#js-next').on('click', function () {
            if ($(this).closest('.page-item').hasClass('disabled')) {
                return false;
            }
            $('#user-table tbody').html('');
            var next = db.collection("employees")
                .startAfter(lastVisible)
                .limit(3);
            next.get().then(function (documentSnapshots) {
                documentSnapshots.docs.forEach(doc => {
                    renderUser(doc);
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

        //document.getElementById('proImage').addEventListener('change', readImage, false);        
        
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

        //# sourceURL=user.js 

    });

    function rowClick(id, avatar, name, year, phone) {              
        $('#edit-user-form').attr('edit-id', id);
        $('#edit-user-form #avatar-preview').attr("src", avatar);        
        $('#edit-user-form #user-name').val(name);
        $('#edit-user-form #user-year').val(year);
        $('#edit-user-form #user-phone').val(phone);
        $('#editUserModal').modal('show');      
    }


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

