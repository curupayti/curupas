$(document).ready(function () {

    db.collection("titles").doc("home")
    .onSnapshot(function(doc) {          
        exist = true;
        console.log("Document data:", doc.data());
        $("#title").val(doc.data().title);
        $("#description").text(doc.data().description);          
    });

    $("#updateButton").on("click", function(e) {
        e.preventDefault();   
    });

    $("#submitTittle").on("click", function(e) {      
        e.preventDefault();        
        var now = firebase.firestore.FieldValue.serverTimestamp();
        var title = {
            title: $('#title').val(), 
            description: $("#description").val(),            
            updatedAt: now
            //updatedBy : user.name
        };
        db.collection("titles").doc("home").set(title).then(()=>{        
            $('#editTitleModal').modal('hide');
        });

        return false;
    });
});