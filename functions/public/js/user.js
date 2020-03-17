    $(document).ready(function () {

        let _documents = {};       
        
        window.jsonData = [];

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
                phone: document.data().phone,
                accepted: document.data().accepted
            };            

            window.datatable = $('#grid-users').DataTable( {
                scrollY: "180px",
                scrollCollapse: true,
                paging:         false,
                retrieve: true, 
                bInfo : false,                                                       
                columns: [                  
                  { "data": "meta.id" },
                  { "data": "meta.Imagen" },
                  { "data": "meta.Nombre" },
                  { "data": "meta.Camada" },                  
                ],
                columnDefs: [
                  {
                    "targets": [ 0 ],
                    "visible": false,
                    "searchable": false,                
                  },                  
                  {
                    "visible": true,
                    "searchable": true,
                    "width": "30%"
                  },
                  {
                    "targets": [ 2 ],
                    "visible": true,
                    "searchable": true,
                    "width": "15%"
                  },
                  {
                    "targets": [ 3 ],
                    "visible": true,
                    "searchable": false,
                    "width": "20%"
                  }
                ],    
                dom: 'Bfrtip',
                buttons: {
                  buttons: [
                    {
                      text: "Nuevo",
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

              let row = { 
                "meta": {                    
                  "id": itemObj.id, 
                  "Imagen": "<img src='" + itemObj.avatar + "' style='height:30px; width:30px'>",                 
                  "Nombre": itemObj.name, 
                  "Camada": itemObj.year, 
                 } 
              };   
   
              window.jsonData.push(row);

              window.datatable.rows.add(window.jsonData);
              window.datatable.draw();  

            /*let item = `<tbody onclick="rowClick('` 
                + itemObj.id + `','`     
                + itemObj.avatar + `','`               
                + itemObj.name + `','` 
                + itemObj.year + `','` 
                + itemObj.phone + `','` 
                + itemObj.accepted + `');"><tr data-id="${itemObj.id}">
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
            $('#user-table').append(item);*/                   
            
            /*var checkbox = $('table tbody input[type="checkbox"]');
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
            });*/

            if (contLoded==(size-1)) {
                homeLoader.hide();
            }
            contLoded++;
        }               

        // VIEW IMAGES
        //$(document).on('click', '.js-view-images', function () {
        //    alert('clicked!');
        //});               

        $("#edit-user-form").submit(function (event) {
            event.preventDefault();
            
            
            /*let id = $(this).attr('edit-id');
            db.collection('employees').doc(id).update({
                name: $('#edit-user-form #employee-name').val(),
                email: $('#edit-user-form #employee-email').val(),
                address: $('#edit-user-form #employee-address').val(),
                phone: $('#edit-user-form  #employee-phone').val()
            });*/

            $(evt.target).is(':checked');


            $('#editUserModal').modal('hide');
        });

        $("#addUserModal").on('hidden.bs.modal', function () {
            $('#add-user-form .form-control').val('');
        });

        $("#editUserModal").on('hidden.bs.modal', function () {
            $('#edit-user-form .form-control').val('');
            //$('#edit-user-form .dropdown-menu').children().remove(); 
            $("#dropdown-button").find('.appended').remove();
            $("#dropdown-role").children().remove(); 
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

        /*Spinner*/

        function modal(){
        $('.modal').modal('show');
            setTimeout(function () {
                console.log('hejF');
                $('.modal').modal('hide');
            }, 3000);
        }

        db.collection("roles").get().then(function(querySnapshotRole) {
            querySnapshotRole.forEach(function(docRole) {                               
                _roleSnapshot.push({
                    id:docRole.id,
                    role: docRole.data().role
                });
            });
        });


        //# sourceURL=user.js 

    });

    let _roleSnapshot = [];   

    /*function rowClick(id, avatar, name, year, phone, accepted) {              
        $('#edit-user-form').attr('edit-id', id);
        $('#edit-user-form #avatar-preview').attr("src", avatar);        
        $('#edit-user-form #user-name').val(name);
        $('#edit-user-form #user-year').val(year);
        $('#edit-user-form #user-phone').val(phone);

        if (accepted) {
            $('#enableUser').attr('checked','checked');
        }

        let roleReference = _user.roleReference;
        let activeRole = roleReference.id;
        let length = _roleSnapshot.length;
        for (var i=0; i<length;i++){
            let _role = _roleSnapshot[i];
            let id = _role.id;
            let role = _role.role;
            let _class = ' class="dropdown-item';
            if (id==activeRole) {
                _class += ' active"';
                $("#dropdown-button").append('<span class="appended">' + role + '</span>');
            } else {
                _class += '"';
            }            
            let _html = '<a id="' + id + '"' + _class + ' href="#">' + role + '</a>';
            $("#dropdown-role").append(_html);
        }
        $('#editUserModal').modal('show');                    

        $(".dropdown-menu a").click(function() {

            $(this).closest('.drop-group').find(".dropdown-menu a").removeClass('active');
            $(this).addClass('active');
          
            $(this).closest('.drop-group').find('.appended').remove();
            $(this).closest('.drop-group').find('button').append('<span class="appended">' + $(this).text() + '</span>');
          
        });
    }*/


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

