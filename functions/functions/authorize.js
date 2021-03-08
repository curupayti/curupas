
   exports.users = functions.firestore
      .document('users/{userId}')
      .onWrite( async (change,contex) => {

      const dataAfter  = change.after.exists ? change.after.data() : null;
      const dataBefore = change.before.data();

  		//var data = snap.data();   

      var roleRef = dataAfter.roleRef; 
      var yearRef = dataAfter.yearRef;

      //console.log("roleRef: " + JSON.stringify(roleRef));
      
      //console.log("yearRef: " + JSON.stringify(yearRef));
      //console.log("yearRef: " + yearRef.id);

      let groupRef = await firestore.collection("roles").doc("group");

      console.log("");
      console.log("roleRef: " + roleRef.id);      
      console.log("groupRef: " + groupRef.id);
      console.log("");

      if (roleRef.id === groupRef.id) {

        console.log("USER IS GROUP MEMBER OF: " + yearRef.id);

        let docYear = await yearRef.get();
        let docYearId = docYear.id;

        console.log("docYearId: " + docYearId);

        const documentId = contex.params.userId;

        console.log("documentId: " + documentId);

        let _time = admin.firestore.FieldValue.serverTimestamp();              

        /*firestore.collection("years").doc(docYearId).set({                   
          users_autorization: [documentId],          
          last_update: _time 
        },{ merge: true });*/

        firestore.collection("years").doc(`${docYearId}`)
        .collection("user-auth").add({          
          userId: documentId,      
          userRef: firestore.doc('users/' + documentId),
          authorized: false,
          last_update: _time 
        },{ merge: true });        

      } 

      /*var registered = 	data.registered;   
      var authorized =  data.authorized;  
      const documentId = contex.params.postId; 

      console.log("registered: " + registered);
      console.log("authorized: " + authorized);    

      if (registered && !authorized) {

        //CREATE AUTHORIZATION

        let year = data.year; 
         



        var autoId = generateShortId();

        var _time =  new Date();        
        var path = "/posts/" + documentId;

        var item = {};        
        item.id = autoId; 
        item.document_path = path;
        item.last_update = _time;

        var _share = "https://app.curupas.com.ar/share/" + autoId; 

        await firestore.collection("share").doc(autoId).set(item,{merge:true});   

        firestore.collection("authorizations").doc(documentId).set({                   
          share: _share,          
          last_update: _time 
        },{ merge: true });


      } */   	

  });   


  exports.authorizations = functions.firestore
    .document('authorizations/{authorizationId}')
    .onWrite( async (snap,contex) => {



  });
