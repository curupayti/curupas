
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

        const documentId = contex.params.userId;

        console.log("documentId: " + documentId);

        let _time = admin.firestore.FieldValue.serverTimestamp();                    

        //SEND NOTIFICATION TO REFERENTS
        //CREATE CALENDAR 

        firestore.collection("years").doc(`${docYearId}`)
        .collection("user-auth").add({          
          userId: documentId,      
          userRef: firestore.doc('users/' + documentId),
          authorized: false,
          stage:1,
          last_update: _time 
        },{ merge: true });        

      } 
   
  });   


  exports.authorizations = functions.firestore
    .document('authorizations/{authorizationId}')
    .onWrite( async (snap,contex) => {



  });
