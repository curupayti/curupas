$(document).ready(function () {

    let name = _user.name;
    let role_desc = _role.desc;
     

    /*Spinner*/

    function modal(){
       $('.modal').modal('show');
       setTimeout(function () {
       	console.log('hejF');
       	$('.modal').modal('hide');
       }, 3000);
    }

    // REAL TIME LISTENER
    db.collection('streaming').onSnapshot(snapshot => {
       
        let size = snapshot.size;
        $('.count').text(size);        
       
        let changes = snapshot.docChanges();
        changes.forEach(change => {

            const newValue = change.doc.data();
           
            if (newValue.url_authorization) {

                let url_authorization = newValue.url_authorization;

                $("#authorization_url").empty();

                let _url = '<a href="' + url_authorization + '" target="_blank">' + url_authorization + '</a>';
                $("#authorization_url").append(_url);
            }

            if (newValue.code) {

                let code = newValue.code;

                $("#code").empty();                
                $("#code").append(code);
            }

            if (newValue.scope) {

                let scope = newValue.scope;

                let _url_scope = '<a href="' + scope + '" target="_blank">' + scope + '</a>';

                $("#scope").empty();                
                $("#scope").append(_url_scope);
            }
            

            if (newValue.tokens) {
                
                let access_token = newValue.tokens.access_token;

                $("#access_token").empty();                
                $("#access_token").append(access_token);

                let refresh_token = newValue.tokens.refresh_token;

                $("#refresh_token").empty();                
                $("#refresh_token").append(refresh_token);

                let expiry_date = newValue.tokens.expiry_date;

                $("#expiry_date").empty();                
                $("#expiry_date").append(expiry_date);


            }

           
            
        });
    });

    $("#get-code").click(function () {

        $("#code-spinner").addClass("fa-spinner fa-spin");

        db.collection('streaming')
        .doc("control").delete().then(document => {

            db.collection('streaming').doc("control")
                .set({
                    fetch_code_trigger:true,
                    fetch_token_trigger:false,
                    get_playlists: false
                },{ merge: true }).then(docRefSet => { 

                    $("#authorization_url").empty();
                    $("#code").empty();
                    $("#scope").empty();
                    $("#access_token").empty();
                    $("#refresh_token").empty();
                    $("#expiry_date").empty();
                    $("#expiry_date").empty();
            });
        
        }).catch((error) => {
                
            console.log("error: " + error);

        });

    });


    $("#get-token").click(function () {

        $("#token-spinner").addClass("fa-spinner fa-spin");

        db.collection('streaming').doc("control")
            .set({
                fetch_token_trigger:true
            },{ merge: true }).then(docRefSet => { 
        }); 
    });


    $("#get-playlist").click(function () {

        $("#token-spinner").addClass("fa-spinner fa-spin");

        db.collection('streaming').doc("control")
            .set({
                fetch_token_trigger:true
            },{ merge: true }).then(docRefSet => { 
        }); 
    });
   
 


    //# sourceURL=streaming.js   
    

});