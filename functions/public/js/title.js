$(document).ready(function () {

    db.collection("titles").doc("home")
    .onSnapshot(function(doc) {          
        exist = true;
        console.log("Document data:", doc.data());
        $("#app-title").val(doc.data().title);
        $("#app-description").text(doc.data().description);          
        $("#app-version").val(doc.data().version);          
    });

    $("#updateButton").on("click", function(e) {
        e.preventDefault();   
    });

    $("#submitTittle").on("click", function(e) {      
        e.preventDefault();        
        var now = firebase.firestore.FieldValue.serverTimestamp();
        var title = {
            title: $('#app-title').val(), 
            description: $("#app-description").val(),            
            updatedAt: now,
            version: $('#app-version').val()
            //updatedBy : user.name
        };
        db.collection("titles").doc("home").set(title).then(()=>{        
            $('#editTitleModal').modal('hide');
        });

        return false;
    });
});