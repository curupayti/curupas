
   exports.users = functions.firestore
      .document('users/{userId}')
      .onWrite( async (change,contex) => {

      const dataAfter  = change.after.exists ? change.after.data() : null;
      const dataBefore = change.before.data();

      var stage = dataAfter.stage; 

      var roleRef = dataAfter.roleRef; 
      var yearRef = dataAfter.yearRef;
    
      let groupRef = await firestore.collection("roles").doc("group");

      console.log("");
      console.log("stage: " + stage);      
      console.log("roleRef: " + roleRef.id);      
      console.log("groupRef: " + groupRef.id);
      console.log("");

      if ( (stage===0) && (roleRef.id === groupRef.id) ) {

        console.log("USER IS GROUP MEMBER OF: " + yearRef.id);

        let docYear = await yearRef.get();
        let docYearId = docYear.id;

        console.log("docYearId: " + docYearId);

        const userId = contex.params.userId;

        console.log("userId: " + userId);

        let _time = admin.firestore.FieldValue.serverTimestamp();                    
        
        //CREATE CALENDAR 

        var data = snap.data();       
        const birthday = data.birthday;
        var name = data.name;

        var desc = "Cumpleaños de " + name;
        var type = "Camadas";

        var start_time = "00:00";
        var end_time = "24:00";

        const shrs = start_time.split(":")[0];
        const smin = start_time.split(":")[1];

        const ehrs = end_time.split(":")[0];
        const emin = end_time.split(":")[1];

        firestore.collection("calendar")
        .doc(type)
        .collection(type + "_collection")
        .add({
          name,
          summary: desc,
          start: new Date(new Date(start).setHours(shrs, smin, 0)),
          end: new Date(new Date(start).setHours(ehrs, emin, 0)),
          createdAt: new Date(),
        });

        //SAVE USER AND AUTHORIZATION

        await firestore.collection("users").doc(userId).set({stage:1},{merge:true});

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
