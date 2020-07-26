'use strict';
 
  const functions = require('firebase-functions');
  var admin = require('firebase-admin');
  const firebase = require('firebase');
  const backupService = require('@crapougnax/firestore-export-import');

  const Firepad  = require('firepad');
  const jsdom = require("jsdom");
  const { JSDOM } = jsdom;
  
  const cors = require('cors')({ origin: true });

  const mkdirp = require('mkdirp-promise');
  const request = require('request');

  const spawn = require('child-process-promise').spawn;
  const path = require('path');
  const os = require('os');
  const fs = require('fs');

  const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path; 

  const express = require('express');
  const app = express();

  var serviceAccount = require("./key/curupas-app-firebase-adminsdk-5t7xp-cb5f62c82a.json");
  var db_url = "https://curupas-app.firebaseio.com";
  
  var bs = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: db_url
  });
  
  const firestore = admin.firestore(); 

  const firebaseConfig = {
    apiKey: "AIzaSyBJffXixRGSguaXNQxbtZb_am90NI9nGHg",
    authDomain: "curupas-app.firebaseapp.com",
    databaseURL: "https://curupas-app.firebaseio.com",
    projectId: "curupas-app",
    storageBucket: "curupas-app.appspot.com",
    messagingSenderId: "813267916846",
    appId: "1:813267916846:web:529f9c18a84b6b45aa67bf",
    measurementId: "G-2RRZXWLMTL"
  };
  firebase.initializeApp(firebaseConfig);

  // Max height and width of the thumbnail in pixels.
  const THUMB_MAX_HEIGHT = 200;
  const THUMB_MAX_WIDTH = 200;
  // Thumbnail prefix added to file names.
  const THUMB_PREFIX = 'thumb_';

  exports.generateThumbnailFromMetadata = functions.storage.object().onFinalize(async (object) => {  
    
    const filePath = object.name;
    const customMetadata = object.metadata;
    var isThumbnail = false;  
    if (customMetadata.thumbnail === "true") {
      isThumbnail = true;
    }
    
    var customMetadataType = parseInt(customMetadata.type);       

    // Cloud Storage files.
    const bucket = admin.storage().bucket(object.bucket);
    const config = {
      action: 'read',
      expires: '03-01-2500',
    };  

    if (isThumbnail === true) {    

      const file = bucket.file(filePath);
      const contentType = object.contentType; // This is the image MIME type
      const fileDir = path.dirname(filePath);
      const fileName = path.basename(filePath);
      const thumbFilePath = path.normalize(path.join(fileDir, `${THUMB_PREFIX}${fileName}`));
      const tempLocalFile = path.join(os.tmpdir(), filePath);
      const tempLocalDir = path.dirname(tempLocalFile);
      const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);

      // Exit if this is triggered on a file that is not an image.
      if (!contentType.startsWith('image/')) {
        return console.log('This is not an image.');
      }

      if (fileName.startsWith(THUMB_PREFIX)) {
        return console.log('Already a Thumbnail.');
      }    
      
      const thumbFile = bucket.file(thumbFilePath);

      const metadata = {
        contentType: contentType,
        // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
        // 'Cache-Control': 'public,max-age=3600',
      };          
      
      await mkdirp(tempLocalDir);      
      await file.download({destination: tempLocalFile});
      await spawn('convert', [tempLocalFile, '-thumbnail', `${THUMB_MAX_WIDTH}x${THUMB_MAX_HEIGHT}>`, tempLocalThumbFile], {capture: ['stdout', 'stderr']});            
      await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath, metadata: metadata});
      
      
      fs.unlinkSync(tempLocalFile);
      fs.unlinkSync(tempLocalThumbFile);
      
      const results = await Promise.all([
        thumbFile.getSignedUrl(config),
        file.getSignedUrl(config),
      ]);
      
      console.log('Got Signed URLs.');
      const thumbResult = results[0];
      const originalResult = results[1];
      const thumbFileUrl = thumbResult[0];     

      //Save Post/Museum Thumbnail
      if (customMetadataType === 1) {  
    
        let _id1 = customMetadata.id;
        let _collection = customMetadata.collection; 
        let _time = admin.firestore.FieldValue.serverTimestamp();
        
        await firestore.collection(_collection).doc(_id1)
          .update({thumbnailSmallUrl: thumbFileUrl, timeStamp:_time})
          .catch((error) => {
            console.log('Error updating:', error);
            return error;
          });
    
      //Save User Thumbnail
      } else if (customMetadataType === 2) {  

        const fileUrl = originalResult[0];    
        let userId = customMetadata.userId;           
        
        let _time = admin.firestore.FieldValue.serverTimestamp();     
        
        await firestore.collection("users").doc(userId).update(
        { 
            profilePictureURL : fileUrl,
            thumbnailPictureURL: thumbFileUrl, 
            profilePicture : filePath,
            thumbnailPicture : thumbFilePath,          
            last_update:_time
        }).catch((error) => {
          console.log('Error updating collection:', error);
          return error;
        });

      // Update content  
      } else if (customMetadataType === 3) {  

          let fileUrl = originalResult[0];            
          let _short = customMetadata.short;          
          let _id2 = customMetadata.id;    
          let _time = admin.firestore.FieldValue.serverTimestamp();             

          await firestore.collection('contents')
          .doc(_short)
          .collection("collection")
          .doc(_id2)
          .update({ 
            storage_icon_ref : filePath,
            storage_thumbFile_ref : thumbFilePath,
            icon_original : fileUrl,
            icon: thumbFileUrl, 
            last_update: _time 
          }).catch((error) => {
            console.log('Error updating collection:', error);
            return error;
          });                     
      
        // Save Media thumbnail image and video  
        } else if (customMetadataType === 4) {  

          let documentId = customMetadata.documentId;
          let doc_name_title = customMetadata.doc_name_title;
          let title = customMetadata.title;
          let desc = customMetadata.desc; 
          let userId = customMetadata.userId;              
          
          let _time = admin.firestore.FieldValue.serverTimestamp();    

          let fileUrl = originalResult[0]; 

          await firestore.collection('years')
          .doc(documentId)
          .collection("media")
          .doc(doc_name_title)
          .set({ 
            type: 2,
            thumbnail : thumbFileUrl,
            image : fileUrl,
            title : title,
            desc: desc, 
            userId : userId,
            aprroved: false,
            last_update: _time 
          }).catch((error) => {
            console.log('Error setting collection:', error);
            return error;
          });   
      
        // Udate user avatar
        } else if (customMetadataType === 5) {  

          let fileUrl = originalResult[0];    
          let userId = customMetadata.userId; 
          let profilePictureToDelete = customMetadata.profilePictureToDelete;         
          let thumbnailPictureToDelete = customMetadata.thumbnailPictureToDelete;           

          let _time = admin.firestore.FieldValue.serverTimestamp();

          firestore.collection("users").doc(userId).update(
          { 
              "profilePictureURL" : fileUrl,
              "thumbnailPictureURL": thumbFileUrl, 
              "profilePicture" : filePath,
              "thumbnailPicture" : thumbFilePath,          
              "last_update" :_time
          }).catch((error) => {
            console.log('Error updating collection:', error);
            return error;
          });

          //Borra imagenes viejas. 
          bucket.file(profilePictureToDelete).delete();
          bucket.file(thumbnailPictureToDelete).delete();

      // Notification
      } else if (customMetadataType === 6) { 

          let fileUrl = originalResult[0];             
          let notificationId = customMetadata.notificationId;        

          //console.log("::notificationId:: " + notificationId);         

          let _time = admin.firestore.FieldValue.serverTimestamp();              

          firestore.collection("notifications").doc(notificationId).update(
          { 
              "imageURL" : fileUrl,
              "thumbnailImageURL": thumbFileUrl,               
              "last_update" :_time
          }).catch((error) => {
            console.log('Error updating collection:', error);
            return error;
          });
        
      }
      
    } else { // not isThiumbnail

      //console.log("::customMetadataType:: " + customMetadataType);  

      if (customMetadataType === 1) { 
        
        /**
         * Years
         */
        
        let file = object.name;
        let thumbFileExt       = 'jpg';
        let fileDir = path.dirname(filePath);
        //let fileName = path.basename(filePath);

        let fileInfo = parseName(file);

        let thumbFilePath = path.normalize(path.join(fileDir, `${fileInfo.name}-thumbnail.${thumbFileExt}`));
        let tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);
        let tempLocalDir       = path.join(os.tmpdir(), fileDir);
      
        await mkdirp(tempLocalDir);
        console.log("tempLocalThumbFile:: " + tempLocalThumbFile);
        let videoFile = bucket.file(file);
        let signedVideoUrl = await videoFile.getSignedUrl(config);             
        let videoUrl = signedVideoUrl[0];        
        console.log("videoUrl:: " + videoUrl);        
        await spawn(ffmpegPath, ['-ss', '0', '-i', videoUrl, '-f', 'image2', '-vframes', '1', '-vf', `scale=${THUMB_MAX_WIDTH}:-1`, tempLocalThumbFile]);
        await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath});      
        await fs.unlinkSync(tempLocalThumbFile);   

        let documentId = customMetadata.documentId;
        let doc_name_title = customMetadata.doc_name_title;
        let title = customMetadata.title;
        let desc = customMetadata.desc; 
        let userId = customMetadata.userId;              
        
        let _time = admin.firestore.FieldValue.serverTimestamp();            
        let fileThumb = bucket.file(thumbFilePath);
        
        // Get the Signed URLs for the thumbnail and original image.
        let signedUrl = await fileThumb.getSignedUrl(config);
        let thumbResult = signedUrl[0];

        console.log('thumbResult: ' + thumbResult);
        
          await firestore.collection('years')
          .doc(documentId)
          .collection("media")
          .doc(doc_name_title)
          .set({ 
            type: 1,
            thumbnail : thumbResult,
            video : videoUrl,
            title : title,
            desc: desc, 
            userId : userId,
            aprroved: false,
            last_update: _time 
          }).catch((error) => {
            console.log('Error setting collection:', error);
            return error;
          });
      
      } else if (customMetadataType === 2) {  

          /**
           * Content Images Attached to Editor
           */ 

          let fileUrl = originalResult[0];            
          let _short = customMetadata.short;          
          let _id3 = customMetadata.id;    
          let _time = admin.firestore.FieldValue.serverTimestamp();             

          await firestore.collection('contents')
          .doc(_short)
          .collection("collection")
          .doc(_id3)
          .set({ 
            sharedWith: [{ fileUrl }],            
            last_update: _time,
            merge: true
          }).catch((error) => {
            console.log('Error updating collection:', error);
            return error;
          });                     
      
        // Save Media thumbnail image and video  
        }
    }

    function parseName(fileName) {
        let _file = path.basename(fileName);
        let _name = _file.replace(/\.[^/.]+$/, "");      
        return { name : _name };
    } 

  });

  exports.sendNotification = functions.firestore
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

  exports.sendSMS = functions.https.onRequest((req, res) => {
    
      const phone = req.body.data.phone;
      const payload = req.body.data.payload;
      const userId = req.body.data.userId;

      var headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 7FA7ED241142E7BE36671CE0FEC9E84F'
      };

      var dataString = '{"recipient":' + phone + ',"message":"' + payload + '"}';  

      var options = {
          url: 'https://api.notimation.com/api/v1/sms',
          method: 'POST',
          headers: headers,
          body: dataString
      };  

      request(options, function (error, response, body) {

          if (!error) {

              let _body = JSON.parse(body);
              console.log("body: " + JSON.stringify(_body));              
              
              let data = _body["data"];
              console.log("data: " + JSON.stringify(data));              
              
              let smsid = data["sms_id"];                         
              console.log("smsid: " + smsid);
              
              let userRef = firestore.collection("users").doc(userId);
              
              return userRef.update({
                smsId: smsid
              })
              .then(function() {
                  res.send(body); 
                  return body;
              }).catch((error) => {
                console.log('Error updating document:', error);
                res.send(e);
                return error;
              });                         
              
          } else {

              var _error = JSON.parse(error);
              res.send(_error);
              return error;
          }
          
      }).catch((error) => {
        console.log('Error posting SMS:', error);        
        return error;
      });  

  });  


  exports.getClassBuckup = functions.https.onRequest((req, res) => {       

      let collections = req.body.collections; //['languages', 'roles'];        
    
        let promises = [];       
        
        try {

         collections.map(collection =>
                promises.push(
                    firestoreService.fixtures(
                        path.resolve(__dirname, `./${collection}.json`),
                        [],
                        [],
                        bs,
                    ),
                ),
            );            
            
            //Promise.all(promises).then(process.exit);
            //let _collJson = JSON.stringify(promises);

           return Promise.all(promises).then(responses => {
              responses.map(response => write(response));              
              return responses;
            }).then(data => {
              console.log("Second handler", data);
              res.status(200).send(data); 
              return data;
            });            

        } catch (e) {
            console.error(e);
            return e;
        }   

    });

  exports.publish = functions.https.onRequest((request, response) => {
    
    response.set('Access-Control-Allow-Origin', '*');
    response.set('Access-Control-Allow-Credentials', 'true'); // vital

    try {

      if (request.method === 'OPTIONS') {
          
          // Send response to OPTIONS requests
          response.set('Access-Control-Allow-Methods', 'GET');
          response.set('Access-Control-Allow-Headers', 'Content-Type');
          response.set('Access-Control-Max-Age', '3600');
          response.status(204).send('');
      
        } else {
          
          const data = request.body;
          const database_ref = data.database_ref;
          const contentType = data.contentType; 
          const documentId = data.documentId; 

          var firepadRef = firebase.database().ref().child(contentType).child(database_ref);    
          var headless = new Firepad.Headless(firepadRef);  

          return cors(request, response, () => {  
              
              headless.getHtml(function(_html) {           

                firestore.collection("contents")
                .doc(contentType)
                .collection("collection")
                .doc(documentId)
                .set({
                  html : _html,
                  published : true
                },{merge:true})
                .then(() => {

                  console.log('Successfully set');                          
                  let json_resutl_ok = { data: { html: _html, result: true }};
                  response.send(json_resutl_ok); 
                  headless.dispose();
                  return json_resutl_ok;
                  
                }).catch((error) => {

                  let json_resutl_false = { data: { result: false }};                
                  response.send(json_resutl_false);               
                  headless.dispose();
                  return json_resutl_false;

                });              

              }).catch((error) => {                
                console.log('Error henerating HTML');
                return error;
              });

          }).catch((error) => {                
            console.log('Error setting CORS');
            return error;
          });   
      }   

    } catch (e) {
      console.error(e);
      return e;
    } 

  });

  
  
