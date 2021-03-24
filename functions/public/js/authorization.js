    $(document).ready(function () {

        let _documents = {};       
        
        let deleteIDs = [];
        let lastVisible;
        let firstVisible;

        var contLoded = 0;
        var size = 0;        

        db.collection('years').doc(_user.yearReference.id).collection("user-auth")
        .onSnapshot(snapshot => {
            size = snapshot.size             
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


        $("#search-keyword").change(function (e){
            const filteredDocuments = [];
            for(doc in _documents){
                if(_documents[doc].data().name && _documents[doc].data().name.includes(e.target.value)) {
                    filteredDocuments.push(_documents[doc]);
                }
            }
            $('#user-table tbody').html("");
            filteredDocuments.forEach(function(doc) {
                renderUser(doc);
            } )
        });
    

        function renderUser(document) {  
            _documents[document.id] = document;  

            var authId = document.id;
            let authorized = document.data().authorized;
            let userRef = document.data().userRef;

            userRef.get()
            .then(async function (docUser) { 

                var status;

                if (authorized) {
                    status = "Autorizado"
                } else {
                    status = "Pendiente"
                }

                let itemObj = {
                    avatar: docUser.data().thumbnailPictureURL,
                    id: docUser.id,
                    name: docUser.data().name,
                    year: docUser.data().year, 
                    status: status,
                    authorized: authorized,
                    roleRefId: docUser.data().roleRef.id,
                    authId: authId 
                };

                let item = `<tbody onclick="rowClick('` 
                    + itemObj.id + `','`     
                    + itemObj.avatar + `','`               
                    + itemObj.name + `','` 
                    + itemObj.year + `','` 
                    + itemObj.authorized + `','`
                    + itemObj.roleRefId + `','`                     
                    + itemObj.authId + `');"><tr data-id="${itemObj.id}">`;               
                item += `                
                <td>Usuario</td>
                <td>
                    <img id="image_${itemObj.id}" class="rounded-circle avatar-preview-list" width="40" height="40" src="${itemObj.avatar}" alt="your image" />            
                </td>
                <td>${itemObj.name}</td>                
                <td>${itemObj.year}</td>                       
                <td>${itemObj.status}</td>
                </tr></tbody>`;
                $('#user-table').append(item);                   
                if (contLoded==(size-1)) {
                    homeLoader.hide();
                }
                contLoded++;
            });           
        }               

        // VIEW IMAGES
        $(document).on('click', '.js-view-images', function () {
            alert('clicked!');
        });               

        $("#edit-user-form").submit(async function (event) {            
            event.preventDefault();                      
            let userId = $(event.target).attr('edit-id');
            let authId = $(event.target).attr('auth-id');
            let checked = $('#enableUser').is(":checked");             
            var groupText = $("#dropdown-button").find('.appended').text();
            var groupId = $("#dropdown-button").find('.appended').attr("data-id");          

            if (window.authorized != checked) {

                var _json = {};

                if (checked) {

                    if (window.roleRefId != groupId) {

                        _json.roleRef = firestore.doc('users/' + groupId);

                    }

                    _json.authorized = true;

                } else {

                    _json.authorized = false;
                }

                await db.collection('users').doc(userId).set(_json,{merge:true});

                await db.collection('years').doc(_user.yearReference.id)
                        .collection('user-auth').doc(authId).set({authorized:checked},{merge:true});

                ///years/DnEa0Q5unZJXHJluRtt3/user-auth/1C6BMlSf1u2DPf3foWJD

            }

            //db.collection('years').doc(_user.yearReference.id).collection("user-auth").doc();

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

        db.collection("roles").where(firebase.firestore.FieldPath.documentId(), "in", ['group','group-admin'])
        .get().then(function(querySnapshotRole) {            
            querySnapshotRole.forEach(function(docRole) {   
                _roleAuthSnapshot.push({
                    id:docRole.id,
                    role: docRole.data().role
                });                
            });
        });

        //# sourceURL=authorization.js

    });

    let _roleAuthSnapshot = [];   

    function rowClick(id, avatar, name, year, authorized, roleRefId, authId) {    
        
        window.roleRefId = roleRefId;        

        $('#edit-user-form').attr('edit-id', id);
        $('#edit-user-form').attr('auth-id', authId);
        $('#edit-user-form #avatar-preview').attr("src", avatar);        
        $('#edit-user-form #user-name').val(name);
        $('#edit-user-form #user-year').val(year);
        
        var isAuthorized = (authorized === 'true');
        window.authorized = isAuthorized;

        if (isAuthorized) {
            $('#enableUser').prop('checked',true);
        } else {
            $('#enableUser').prop('checked',false);
        }       
        let activeRole = roleRefId;
        let length = _roleAuthSnapshot.length;
        for (var i=0; i<length;i++){
            let _role = _roleAuthSnapshot[i];
            let id = _role.id;
            let role = _role.role;
            let _class = ' class="dropdown-item';
            if (id==activeRole) {
                _class += ' active"';
                $("#dropdown-button").append('<span class="appended" data-id='+ activeRole +'>' + role + '</span>');
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

