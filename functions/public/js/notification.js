$(document).ready(function () {

    let lastVisible;
    let firstVisible;

    window.roles = [];
    var years = [];
    var allUsers = [];

    window.checked_users = [];

    var count = 0;

    let data_all = {name: "Todos los usuarios", role: 1};
    window.roles.push(data_all);

    db.collection("roles").get()
    .then(function(querySnapshotRoles) {
        querySnapshotRoles.forEach(function(doc) { 
            var _name = doc.id;
            var roleData = doc.data();
            var _role = roleData.role;            
            var _roleRef = doc.ref;            
            let data = {name: _role, roleRef: _roleRef, role: "roles/" + _name, id: count};
            window.roles.push(data);
            count++;
        });        
    })
    .catch(function(error) {
        console.log("Error getting documents: ", error);
    }); 
    
    db.collection("years").get()
    .then(function(querySnapshot) {
        querySnapshot.forEach(function(doc) {                    
            console.log(doc.id, " => ", doc.data());
            let number = parseInt(doc.data().year);
            years.push(number)
            // $("#group").append($('<option>').text(doc.data().year).attr('value', number));
        });
    })
    .catch(function(error) {
        console.log("Error getting groups: ", error);
    }); 
    


    db.collection("groups").get()
    .then(function(querySnapshot) {
        querySnapshot.forEach(function(doc) {                    
            console.log(doc.id, " => ", doc.data());
            let number = parseInt(doc.data().year);
            $("#destiny").append($('<option>').text(doc.data().year).attr('value', number));
        });
    })
    .catch(function(error) {
        console.log("Error getting documents: ", error);
    }); 
    
    //$("#destiny").append($('<option>').text("1973").attr('value', -1));

    $("#destiny").change(function() {

        var selectedDestiny = this.value;
        var selectedText = this.text;
        if (selectedDestiny == 0){
            topic = "users";
        } else {
            topic = selectedText;
        }               
    });    

    // REAL TIME LISTENER
    db.collection('notifications').onSnapshot(snapshot => {       
        let changes = snapshot.docChanges();
        changes.forEach(change => {
            if (change.type == 'added') {
                renderNotification(change.doc);
            } else if (change.type == 'modified') {
                $('tr[data-id=' + change.doc.id + ']').remove();
                renderNotification(change.doc);
            } else if (change.type == 'removed') {
                $('tr[data-id=' + change.doc.id + ']').remove();
            }
        });
    });

    function renderNotification(document) {        
        let _time = formatDate(Date(document.data().timeStamp));         
        let item = `<tr data-id="${document.id}">        
        <td>${document.data().title}</td>
        <td>${document.data().notification}</td>           
        <td>${document.data().notificationTopic}</td>  
        <td>${_time}</td>      
        </tr>`;
        $('#employee-table').append(item);                     
    }

    // VIEW IMAGES
    $(document).on('click', '.js-view-images', function (event) {
       
    });

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

    // ADD EMPLOYEE
    $("#add-notification-form").submit(function (event) {
        event.preventDefault();       
        var title = $('#title').val();
        var notification = $('#notification').val();          
        
        $('.lds-dual-ring').css('visibility', 'visible');

        db.collection("notifications").add({
            title: title,
            notification: notification,
            //author: user.email
        })
        .then(function(docRef) {
            $('#addNotificationModal').modal('hide');
        })       
        .catch(function(error) {
            console.error("Error adding document: ", error);
        });   
    });
    
    $("#addNotificationModal").on('hidden.bs.modal', function () {
        $('#add-notification-form .form-control').val('');
    });  

    $("#addNotificationModal").on('show.bs.modal', function () {

        // $(this).find('.modal-content').css({
        //     width:'800px',                               
        // });

        // $(this).css({            
        //     transform: 'translateX(-20%)',
        //     'overflow-y': 'hidden'
        // });

        clearData();
        
        let length = window.roles.length;              
        
        for (var i=0; i<length;i++){
            let data = window.roles[i];
            let content = data.name;        
            let id = data.id;
            var addoption = $('<option></option>').val(id).text(content);                       
            $('#destiny').append(addoption);            
        } 

        var yearsLength = years.length;
        for (var i=0; i<yearsLength;i++){
            let data = years[i];
            var addoption = $('<option></option>').val(data).text(data);
            console.log(years, addoption);
            
            $('#grouptest').append(addoption);
        } 

        //Limpiar combo al entrar y verificar cual id es el que esta en foco. 
        //$('#destiny').val(0);
        loadAllUsers();
    });  

    $('#destiny').on('change', function(e){               
      
        let value = $(this).val();          
        
        clearData();        
        
        // if (value==0) {
            // loadAllUsers();
        // } else {
            loadSelectorByRole(value);        
        // }       

    });

    $('#grouptest').on('change', function(e){               
        let destiny = $('#destiny').val();
        let roleObject = destiny ? window.roles[destiny] : {};
        let rolRef = roleObject.roleRef;
        clearData();
        $("#search-user").val('');
        
        let group = e.target.value;
        var count = 0;
        var filteredUsers = allUsers.filter((doc) => {
          return (
            ((destiny ? doc.data().roleRef.path === rolRef.path : true) &&
              (group ? doc.data().year == group : true)) ||
            checked_users.indexOf(doc.id) > -1
          );
        });
        filteredUsers.forEach(function(doc) {                           
            populateUserTable(doc, count);
            count++;           
        });
        
    })

    function clearData() {

        $('#usersTable').empty();

        let header = `<thead>
            <tr>
                <th scope="col"></th>
                <th scope="col">Nombre</th>
                <th scope="col">Camada</th>                                                                    
                <th scope="col" style="display:none">id</th>
            </tr>
        </thead>`;

        $('#usersTable').append(header);
    }

    function loadSelectorByRole(id) {
        let roleObject = window.roles[id];
        let rolRef = roleObject.roleRef;
        let name = roleObject.name;

        $('#titulo-selected').text(name);
        $("#search-user").val('');
        let group = $('#grouptest').val();
        console.log(window.roles, id, rolRef);
        
        var count = 0;
        var filteredUsers = allUsers.filter((doc) => {
          return (
            ((rolRef ? doc.data().roleRef.path === rolRef.path : true) &&
              (group ? doc.data().year == group : true)) ||
            checked_users.indexOf(doc.id) > -1
          );
        });

        filteredUsers.forEach(function(doc) {                           
            populateUserTable(doc, count);
            count++;           
        });
    }



    function loadAllUsers() {

        let roleObject = window.roles[0];
        let name = roleObject.name;

        $('#titulo-selected').text(name);

        var count = 0;
        var usersRef = db.collection("users").get()
        .then(function(querySnapshot) {
            querySnapshot.forEach(function(doc) {
                if (doc.id != "init") {
                    allUsers.push(doc);
                    populateUserTable(doc, count);
                    count++;
                }
               
            });
        })
        .catch(function(error) {
            console.log("Error getting documents: ", error);
        });
    }

    $("#search-user").change((e) => {
        let destiny = $('#destiny').val();

        let roleObject = destiny ? window.roles[destiny] : {};
        let rolRef = roleObject.roleRef;
        let group = $('#grouptest').val();

        var count = 0;
        clearData();        
        
        var filteredUsers = allUsers.filter(
          (doc) =>
            ((destiny ? doc.data().roleRef.path === rolRef.path : true) &&
              (group ? doc.data().year == group : true) &&
              doc
                .data()
                .name.toLowerCase()
                .includes(e.target.value.toLowerCase())) ||
            checked_users.indexOf(doc.id) > -1
        );
        filteredUsers.forEach(function(doc) {                           
            populateUserTable(doc, count);
            count++;           
        });

    })

    function populateUserTable(doc, id) {                

        let data = doc.data();

        // window.checked_users[id] = data;

        let name = data.name;
        let year = data.year;
        let docId = doc.id;
        let row = `<tr>
            <th class="active">
                <input type="checkbox" ${
                  checked_users.indexOf(docId) > -1 ? "checked" : ""
                } onchange="selectUser('${docId}')" class="userCheckbox select-all checkbox" name="select-all" />
            </th>
            <th>${name}</th>            
            <th>${year}</th>
            <th class="id" style="display:none">${doc.id}</th>            
        </tr>`;

        $('#usersTable').append(row);
    }

    window.selectUser = function (id) {
      if (checked_users.indexOf(id) > -1) {
        checked_users = checked_users.filter((v) => v !== id);
      } else {
        checked_users.push(id);
      }
    };

    $(".userCheckbox").change(function () { 
        alert("Event is bound");
    });

    //button select all or cancel
    $("#select-all").click(function () {
        var all = $("input.select-all")[0];
        all.checked = !all.checked
        var checked = all.checked;
        $("input.select-item").each(function (index,item) {
            item.checked = checked;
        });
    });

    $("#submitNotification").click(function (e) {        
        e.preventDefault();

        var userdata = []; 

        checked_users.forEach(function(v){
            const user = allUsers.find((doc)=>doc.id == v);
            // var id,toArea,checkBox;
            // id = $(this).closest('tr').find('.id').html();
            // let _userData = window.checked_users[id];
            let data = {token:user.data().token, userID:user.data().userID};             
            userdata.push(data);
        });

        var length = userdata.length;

        if (length>0) {                          

            var titletext = $("#titletext").val();
            var notitext = $("#notitext").val();
            var now = firebase.firestore.FieldValue.serverTimestamp();

            var notificationRef = db.collection("notifications").doc();            

            notificationRef.set({
            
                title: titletext, 
                notification: notitext,                 
                last_update: now,            
            
            }).then(() => {    
                
                notificationRef.get().then(document => {                   

                    var storageRef = storage.ref("notifications/" + document.id);        
                    var file = $('#imgInp').get(0).files[0]; //document.getElementById("imgInp").files[0];                 
                    let rnd = Math.floor((Math.random()) * 0x10000).toString(7);  
                    
                    var newString = titletext.replace(/[^A-Z0-9]/ig, "_");
                    var filePath = newString + "_" +  rnd + ".png";            
                    
                    var thisRef = storageRef.child(filePath);                         

                    var metadata = {
                        customMetadata: {
                            'thumbnail': 'true',
                            'type' : '6',                    
                            'notificationId' : document.id                
                        }
                    }
                    
                    thisRef.put(file, metadata);

                    var document_path = "notifications/" + document.id + "/user-token-chat";
                    for (var i=0; i<length; i++) {
                        db.collection(document_path).add( {                        
                            token: userdata[i].token,   
                            userId: userdata[i].userID,                                    
                        });   
                    }   
                    
                    
                    $('#addNotificationModal').modal('hide');
                });  
                  
            });            
        }

    });     

    $("#table tr").click(function(){
        $(this).addClass('selected').siblings().removeClass('selected');    
        var value=$(this).find('td:first').html();
        alert(value);    
     });
     
     $('.ok').on('click', function(e){
         alert($("#table tr.selected td:first").html());
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
                renderNotification(doc);
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
                renderNotification(doc);
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

    //# sourceURL=notification.js 
    
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