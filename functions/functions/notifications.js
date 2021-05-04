
    exports.notification = functions.firestore
      .document('notifications/{notificationsId}')
      .onWrite((change, context) => {    

      const newValue = change.after.data();       
      let thumbnailImageURL = newValue.thumbnailImageURL;

      console.log("thumbnailImageURL " + thumbnailImageURL);

      if (thumbnailImageURL !== undefined) {

        let title = newValue.title;
        let message = newValue.notification;
        let urlimage = newValue.thumbnailImageURL;
        let notificationId = context.params.notificationsId;
        let document_path = "notifications/" + notificationId + "/user-token-chat";
        
        console.log("document_path " + document_path);       
        
        return firestore.collection(document_path).get()      
        .then(function(usersSnapshot) {
            
            usersSnapshot.forEach(function(docUserNotification) {

              let notiData = docUserNotification.data();   
              let token = notiData.token;          

              const payload = {
                "notification": {
                    "title": title,
                    "body": message,
                    "image":urlimage,
                  },
                  "data" : {
                    "notificationId" : notificationId,
                  }
              };      
                            
              console.log("payload " + JSON.stringify(payload));          

              admin.messaging().sendToDevice(token, payload).then(function(response) {
                console.log('Successfully sent message:', response);
                return response;
              }).catch((error) => {
                console.log('Error sending message:', error);
                return error;
              });
              
              return docUserNotification;

            });    

            return null;
        
        }).catch(err=>{
          console.log("error:  " + err);
          return err;
        });  

      } else {
        return {};
      }

    
    });  


    exports.sendNotificationToGroup = functions.https.onCall( async (data, context) => {

    //exports.sendNotificationTo = functions.https.onRequest( async (req, res) => {

        //let data = req.body;

        console.log("LLEGGAAA");

        const title = data.title;
        const notification = data.notification;

        const role = data.role;
        const year = data.year;

        console.log("role: " + role);
        console.log("year: " + year);

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

                    var notificationRef = await firestore.collection("notifications");         
                    var notiDoc = await notificationRef.add({            
                        title: title, 
                        notification: notification,   
                        thumbnailImageURL: user.profilePictureURL,              
                        last_update: new Date(),                        
                    });       

                    var document_path = "notifications/" + notiDoc.id + "/user-token-chat";                 
                    await firestore.collection(document_path).add({                        
                        token: user.token,   
                        userId: user.userID,                                    
                    });
                    

                });
            }

            return {};
        });
     
    });