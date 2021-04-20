
    ///////////////////////////////
    // Ports Opened
    // https://fredriccliver.medium.com/port-8080-is-not-open-on-localhost-could-not-start-firestore-emulator-15c8c367d219#:~:text=This%20error%20is%20because%20of,and%20stop%20the%20previous%20process.
    //////////////////////////////

   exports.users = functions.firestore
      .document('users/{userId}')
      .onWrite( async (change,contex) => {

      const dataAfter  = change.after.exists ? change.after.data() : null;
      const dataBefore = change.before.data();

      var stage = dataAfter.stage; 

      var roleRef = dataAfter.roleRef; 
      var yearRef = dataAfter.yearsRef[0];
    
      let groupRef = await firestore.collection("roles").doc("group");

      console.log("");
      console.log("stage: " + stage);   
      console.log("yearRef id: " + yearRef.id);   
      //console.log("roleRef: " + roleRef.id);      
      console.log("groupRef: " + groupRef.id);
      console.log("");

      if ( (stage===0) && (roleRef.id === groupRef.id) ) {        

        var yearsRefQuery = await firestore.collection('years');
        var yearsQuery = await yearsRefQuery.where('year', '==', 'invitado');//.valueChanges();        
        const querySnapshot = await yearsQuery.get();
        var visitorRef = querySnapshot.docs[0];   

        console.log("Visitor Id: " + visitorRef.id);

        let docYear = await yearRef.get();
        let docYearId = docYear.id;
        console.log("");
        console.log("docYearId: " + docYearId);
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

        //SAVE USER AND AUTHORIZATION

        await firestore.collection("users").doc(userId).set({
          stage:1,
          yearsRef: FieldValue.arrayUnion(...[firestore.doc('years/' + visitorRef.id)]) 
        },{merge:true});

        await firestore.collection("years").doc(`${docYearId}`)
        .collection("user-auth").add({          
          userId: userId,      
          userRef: firestore.doc('users/' + userId),
          authorized: false,          
          last_update: _time 
        },{ merge: true });         

        //SEND NOTIFICATION TO REFERENTS        

      } 
   
  });   


  exports.authorizations = functions.firestore
    .document('authorizations/{authorizationId}')
    .onWrite( async (snap,contex) => {

    

  });

  exports.years = functions.firestore
      .document('years/{yearId}')
      .onWrite( async (change,contex) => {

      const dataAfter  = change.after.exists ? change.after.data() : null;      
      
      var name = dataAfter.name;       
    
      console.log("");
      console.log("name: " + name);      
      console.log("");

});
