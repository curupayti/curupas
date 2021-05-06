
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
        .then( (usersSnapshot) => {
            
            usersSnapshot.forEach( async (docUserNotification) => {

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

              return await sendToDevice();          

            });    

            return {};
        
        }).catch((err) => {
          console.log("error:  " + err);
          return err;
        });  

      } else {
        return {};
      }
    
    });  

    var sendToDevice = function (token, payload) {      
        admin.messaging().sendToDevice(token, payload).then((response) => {
          console.log('Successfully sent message:', response);
          return response;
        }).catch((error) => {
          console.log('Error sending message:', error);
          return error;
        });
      }


    