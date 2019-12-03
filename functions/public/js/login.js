$(document).ready(function () {

    $('#btn-login').click(function(e) {                            
        e.preventDefault(); 
        
        var form = $("#loginForm")

        if (form[0].checkValidity() === false) {
            event.preventDefault()
            event.stopPropagation()
        }           

        var empty = false;        
        var errorMessage; 

        var inputEmail = $("#inputEmail").val();
        var inputPassword = $("#inputPassword").val();          
        

        if ( inputEmail=="" || inputPassword=="") {                                           

            empty = true;             
            let prob = 0;

            if (inputEmail=="" && inputPassword=="") {
                errorMessage = "Los campor email y password están vacios";    
            } else if (inputEmail=="") {
                errorMessage = "El campor email está vacío";    
            } else if (inputPassword=="") {
                errorMessage = "El campor password está vacío";    
            }
            
        }  

        if (empty) {       
            
            $("#message").html(errorMessage);           

            form.addClass('was-validated');
            

        } else {


            firebase.auth().signInWithEmailAndPassword(inputEmail, inputPassword).catch(function(error) {  
                
                //var errorCode = error.code;
                var errorMessage = error.message;  

                $("#message").html(errorMessage);           

                form.addClass('was-validated');

            });

        } 

    });

    //https://www.codeply.com/go/oPUDdgN6CK/bootstrap-4-validation

    //# sourceURL=login.js   

});