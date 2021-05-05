
    ///////////////////////////////
    // Ports Opened
    // https://fredriccliver.medium.com/port-8080-is-not-open-on-localhost-could-not-start-firestore-emulator-15c8c367d219#:~:text=This%20error%20is%20because%20of,and%20stop%20the%20previous%20process.
    //////////////////////////////

  var notificatonToGroup = async function ( data )  {   

        console.log();
        console.log("data: " + JSON.stringify(data));
        console.log();

        var notificationId = data.id;

        const role = data.role;
        const year = data.year;

        console.log();
        console.log("role: " + role);
        console.log("year: " + year);
        console.log();

        let userRef = firestore.collection("users");
        let queryResutl = await userRef
        .where("roleRef", "==", firestore.doc('roles/' + role))
        .where("yearsRef", "array-contains", firestore.doc('years/' + year)).get()
        .then(async (querySnapshot) => {
            
            size = querySnapshot.docs.length;
            console.log("size: "+ size);

            if (size>0) {                   
            
                await querySnapshot.forEach(async (doc) => {

                    let user = doc.data();

                    /*var notificationRef = await firestore.collection("notifications");         
                    var notiDoc = await notificationRef.add({            
                        title: title, 
                        notification: notification,   
                        thumbnailImageURL: user.profilePictureURL,              
                        last_update: new Date(),                        
                    });*/       

                    var document_path = "notifications/" + notificationId + "/user-token-chat";                 
                    await firestore.collection(document_path).add({                        
                        token: user.token,   
                        userId: user.userID,                                    
                    });
                    

                });
            }

            return {};
        });
     
    };

   exports.users = functions.firestore
      .document('users/{userId}')
      .onWrite( async (change,contex) => {

      var dataAfter  = change.after.exists ? change.after.data() : null;
      //const dataBefore = change.before.data();

      var stage = dataAfter.stage; 

      var roleRef = dataAfter.roleRef; 
      var yearRef = dataAfter.yearsRef[0];
    
      let groupRef = await firestore.collection("roles").doc("group");

      console.log("");
      console.log("stage: " + stage);   
      console.log("yearRef id: " + yearRef.id);   
      console.log("roleRef: " + roleRef.id);      
      console.log("groupRef: " + groupRef.id);
      console.log("");

      if ( (stage===0) && (roleRef.id === groupRef.id) ) {        

        var yearsRefQuery = await firestore.collection('years');
        var yearsQuery = await yearsRefQuery.where('year', '==', 'invitado');//.valueChanges();        
        const querySnapshot = await yearsQuery.get();
        var visitorRef = querySnapshot.docs[0];   

        console.log("Visitor Id: " + visitorRef.id);

        //let docYear = await yearRef.get();
        var yearId = yearRef.id;
        console.log("yearId: " + yearId);
        
        console.log("");        
        const userId = contex.params.userId;
        console.log("userId: " + userId);
        console.log("");

        let _time = admin.firestore.FieldValue.serverTimestamp();                    
        
        //CREATE CALENDAR 

        const birthday = dataAfter.birthday;
        var name = dataAfter.name;

        var desc = "Cumpleaños de " + name;
        var type = "Camadas";

        var start_time = "00:00";
        var end_time = "24:00";

        const shrs = start_time.split(":")[0];
        const smin = start_time.split(":")[1];

        const ehrs = end_time.split(":")[0];
        const emin = end_time.split(":")[1];

        await firestore.collection("calendar")
        .doc(type)
        .collection(type + "_collection")
        .add({
          name,
          summary: desc,
          start: new Date(new Date(birthday).setHours(shrs, smin, 0)),
          end: new Date(new Date(birthday).setHours(ehrs, emin, 0)),
          createdAt: new Date(),
        });        

        await firestore.collection("users").doc(userId).set({
          stage:1,
          yearsRef: FieldValue.arrayUnion(...[firestore.doc('years/' + visitorRef.id)]) 
        },{merge:true});

        //SAVE AUTHORIZATION
        await firestore.collection("years").doc()
        .collection("user-auth").add({          
          userId: userId,      
          userRef: firestore.doc('users/' + userId),
          authorized: false,          
          last_update: _time 
        },{ merge: true });              

        //SAVE NOTIFICATION            
        let title = `Nuevo usuario ${name}`;
        let message = `Ingresa al panel y autoriza a ${name} para utilizar la app.`;
        let newNotification = await firestore.collection("notifications").add({            
            title: title, 
            notification: message,   
            thumbnailImageURL: dataAfter.profilePictureURL,              
            last_update: new Date(),                        
        });
        console.log("newNotification::: " + newNotification.id);

        //SEND NOTIFICATION TO REFERENTS  
        var data = {
          //title   : title,
          //message : message,
          id      : newNotification.id, 
          role    : "group-admin",
          year    : yearId
        };
        await notificatonToGroup(data);
      } 
   
  });   

  

