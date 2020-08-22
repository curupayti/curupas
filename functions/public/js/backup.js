$(document).ready(function () {

    let name = _user.name;
    let role_desc = _role.desc;

    $('#welcome').html("Bienvenido " +name);
    $('#role').html(role_desc);    
    
    let lastVisible;
    let firstVisible;

    $("#search-keyword").change(function (e){
        const filteredDocuments = [];
        for(doc in _documents){
            if(_documents[doc].data().title && _documents[doc].data().title.includes(e.target.value)) {
                filteredDocuments.push(_documents[doc]);
            }
        }
        $('#post-table tbody').html("");
        filteredDocuments.forEach(function(doc) {
            renderPost(doc);
        } )
    });

    window.downloadCalss = function (id) {   
        
        $("#icon-" + id).removeClass("fa-download");
        $("#icon-" + id).addClass("fa-spinner fa-spin");

        var settings = {
        "url": "https://us-central1-curupas-app.cloudfunctions.net/backup",
        "method": "POST",
        "timeout": 0,
        "headers": {
                "Content-Type": "application/json"
            },
            "data": JSON.stringify({
                "collection":id                
            }),
        };        
        //homeLoader.show();            
        $.ajax(settings).done(function (response) {            

            let file = JSON.stringify(response);      
            let blob = new Blob([file], {type: "application/json"});                 
            
            let url = window.URL.createObjectURL(blob);      
            
            let element = document.createElement('a');      
            element.setAttribute('href', url);      
            element.setAttribute('download', id + ".json");  
            element.style.display = 'none';
            document.body.appendChild(element);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
            element.click();  
            document.body.removeChild(element);
            
            $("#icon-" + id).removeClass("fa-spinner");
            $("#icon-" + id).addClass("fa-download");
            
        }); 
    }   

    let classesArray = ["calendar","contents","museums","notifications","pages","posts","roles","titles","users","years"];  

    for (var i=0; i<classesArray.length; i++) {        
        renderPost(classesArray[i]);
    }
   
    function renderPost(id) {              
        
        let item = `<tr data-id="${id}">
        <td>${id}</td>        
        <td>            
            <a onClick="downloadCalss(\'${id}\')"><i id="icon-${id}" class="fa fa-download" aria-hidden="true"></i></a>
        </td>        
        </tr>`;
        $('#backup-table').append(item);                   
    }   

  
    // PAGINATION
    $("#js-previous").on('click', function () {
        $('#post-table tbody').html('');
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
        $('#post-table tbody').html('');
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

    /*Spinner*/

    function modal(){
       $('.modal').modal('show');
       setTimeout(function () {
       	console.log('hejF');
       	$('.modal').modal('hide');
       }, 3000);
    }

    //# sourceURL=backup.js   


    

});