$(document).ready(function () {

    let lastVisible;
    let firstVisible;

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
    
    $("#destiny").append($('<option>').text("1973").attr('value', -1));

    $("#destiny").change(function() {

        var selectedDestiny = this.value;
        var selectedText = this.text;
        console.log(selectedDestiny);               
        if (selectedDestiny == 0){
            topic = "users";
        } else {
            topic = selectedText;
        }               
    });

    $("#submitNotification").on("click", function(e) {      
        e.preventDefault();
        var now = firebase.firestore.FieldValue.serverTimestamp();
        var newCityRef = db.collection("notifications").doc();
        var title = $('#title').val();
        var desc = $("#description").val();
        newCityRef.set({
            title: title, 
            description: desc,            
            createdAt: now,
            notificationTopic : topic
        }).then(()=>{        
            $('#addNotificationModal').modal('hide');
        });
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

    // db.collection('employees').startAt("abc").endAt("abc\uf8ff").get()
    // .then(function (documentSnapshots) {
    //     documentSnapshots.docs.forEach(doc => {
    //         renderNotification(doc);
    //     });
    // });

    // db.collection('employees').startAt('bos').endAt('bos\uf8ff').on("value", function(snapshot) {
    //     console.log(snapshot);
    // });
    // var first = db.collection("employees")
    //     .limit(3);

    // first.get().then(function (documentSnapshots) {
    //     documentSnapshots.docs.forEach(doc => {
    //         renderNotification(doc);
    //     });
    //     lastVisible = documentSnapshots.docs[documentSnapshots.docs.length - 1];
    //     console.log(documentSnapshots.docs.length - 1);
    // });


    function renderNotification(document) {        
        let _time = formatDate(Date(document.data().timeStamp));         
        let item = `<tr data-id="${document.id}">        
        <td>${document.data().title}</td>
        <td>${document.data().description}</td>           
        <td>${document.data().notificationTopic}</td>  
        <td>${_time}</td>      
        </tr>`;
        $('#employee-table').append(item);                     
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
    $("#add-notification-form").submit(function (event) {
        event.preventDefault();       
        var title = $('#title').val();
        var description = $('#description').val();          
        
        $('.lds-dual-ring').css('visibility', 'visible');

        db.collection("notifications").add({
            title: title,
            description: description,
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