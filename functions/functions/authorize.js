
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

        //SEND NOTIFICATION TO REFERENTS
        //CREATE CALENDAR 

        await firestore.collection("users").doc(userId).set({stage:1},{merge:true});

        await firestore.collection("years").doc(`${docYearId}`)
        .collection("user-auth").add({          
          userId: userId,      
          userRef: firestore.doc('users/' + userId),
          authorized: false,          
          last_update: _time 
        },{ merge: true });         

      } 
   
  });   


  exports.authorizations = functions.firestore
    .document('authorizations/{authorizationId}')
    .onWrite( async (snap,contex) => {



  });
