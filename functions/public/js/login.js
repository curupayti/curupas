$(document).ready(function () {

    $('#btn-login').click(function(e) {                            
        e.preventDefault(); 

        var inputEmail = $("#inputEmail").val();
        var inputPassword = $("#inputPassword").val();                        

        firebase.auth().signInWithEmailAndPassword(inputEmail, inputPassword).catch(function(error) {  
            var errorCode = error.code;
            var errorMessage = error.message;  
        });

    });

    //https://www.codeply.com/go/oPUDdgN6CK/bootstrap-4-validation

    //# sourceURL=login.js   

});