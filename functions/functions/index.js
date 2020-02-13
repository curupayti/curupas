/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for t`he specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
var admin = require('firebase-admin');

var serviceAccount = require("./key/curupas-app-firebase-adminsdk-5t7xp-cb5f62c82a.json");
var db_url = "https://curupas-app.firebaseio.com";
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: db_url
});
const firestore = admin.firestore();

const firebase = require('firebase');

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

const Firepad  = require('firepad');
const jsdom = require("jsdom");
const { JSDOM } = jsdom;

const cors = require('cors')({origin: true});

const mkdirp = require('mkdirp-promise');
const request = require('request');

const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

// Max height and width of the thumbnail in pixels.
const THUMB_MAX_HEIGHT = 200;
const THUMB_MAX_WIDTH = 200;
// Thumbnail prefix added to file names.
const THUMB_PREFIX = 'thumb_';

/**
 * When an image is uploaded in the Storage bucket We generate a thumbnail automatically using
 * ImageMagick.
 * After the thumbnail has been generated and uploaded to Cloud Storage,
 * we write the public URL to the Firebase Realtime Database.
 */
exports.generateThumbnailFromMetadata = functions.storage.object().onFinalize(async (object) => {  
  
  const filePath = object.name;
  const customMetadata = object.metadata;
  var isThumbnail = (customMetadata.thumbnail == 'true');
  var customMetadataType = parseInt(customMetadata.type);       
  
  console.log("=============== customMetadataType:" + customMetadataType);

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

  // Exit if the image is already a thumbnail.
  if (fileName.startsWith(THUMB_PREFIX)) {
    return console.log('Already a Thumbnail.');
  }

  // Cloud Storage files.
  const bucket = admin.storage().bucket(object.bucket);
  const file = bucket.file(filePath);
  const thumbFile = bucket.file(thumbFilePath);
  const metadata = {
    contentType: contentType,
    // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
    // 'Cache-Control': 'public,max-age=3600',
  };

  //
  const config = {
    action: 'read',
    expires: '03-01-2500',
  }; 

  if (isThumbnail == true) {    
    
    // Create the temp directory where the storage file will be downloaded.
    await mkdirp(tempLocalDir)
    // Download file from bucket.
    await file.download({destination: tempLocalFile});
    console.log('The file has been downloaded to', tempLocalFile);
    // Generate a thumbnail using ImageMagick.
    await spawn('convert', [tempLocalFile, '-thumbnail', `${THUMB_MAX_WIDTH}x${THUMB_MAX_HEIGHT}>`, tempLocalThumbFile], {capture: ['stdout', 'stderr']});
    console.log('Thumbnail created at', tempLocalThumbFile);
    // Uploading the Thumbnail.
    await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath, metadata: metadata});
    console.log('Thumbnail uploaded to Storage at', thumbFilePath);
    // Once the image has been uploaded delete the local files to free up disk space.
    fs.unlinkSync(tempLocalFile);
    fs.unlinkSync(tempLocalThumbFile);
    
    // Get the Signed URLs for the thumbnail and original image.
    const results = await Promise.all([
      thumbFile.getSignedUrl(config),
      file.getSignedUrl(config),
    ]);
    
    console.log('Got Signed URLs.');
    const thumbResult = results[0];
    const originalResult = results[1];
    const thumbFileUrl = thumbResult[0];    

    //Save Post/Museum Thumbnail
    if (customMetadataType == 1) {  
   
      var _id = customMetadata.id;
      var _collection = customMetadata.collection; 
      console.log('_id: '+ _id + " _collection: " + _collection);          
      let _time = admin.firestore.FieldValue.serverTimestamp();
      console.log("_time: " + _time);         
      await firestore.collection(_collection).doc(_id).update({thumbnailSmallUrl: thumbFileUrl, timeStamp:_time});
   
    //Save User Thumbnail
    } else if (customMetadataType == 2) {  

      const fileUrl = originalResult[0];    
      var userId = customMetadata.userId;
      var year = customMetadata.year;
      console.log('year: '+ year);          
      let _time = admin.firestore.FieldValue.serverTimestamp();
      console.log("_time: " + _time);
      await firestore.collection("users").doc(userId).update(
        { profilePictureURL : fileUrl,
          thumbnailPictureURL: thumbFileUrl, timeStamp:_time});

    }
    
  }  

});


/**
 * Initiate a recursive delete of documents at a given path.
 * 
 * The calling user must be authenticated and have the custom "admin" attribute
 * set to true on the auth token.
 * 
 * This delete is NOT an atomic operation and it's possible
 * that it may fail after only deleting some documents.
 * 
 * @param {string} data.path the document or collection path to delete.
 */
/*exports.recursiveDelete = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB'
  })
  .https.onCall((data, context) => {
    // Only allow admin users to execute this function.
    if (!(context.auth && context.auth.token && context.auth.token.admin)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Must be an administrative user to initiate delete.'
      );
    }

    const path = data.path;
    console.log(
      `User ${context.auth.uid} has requested to delete path ${path}`
    );

    // Run a recursive delete on the given document or collection path.
    // The 'token' must be set in the functions config, and can be generated
    // at the command line by running 'firebase login:ci'.
    return firebase_tools.firestore
      .delete(path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
        token: functions.config().fb.token
      })
      .then(() => {
        return {
          path: path 
        };
      });
  });*/


exports.sendNewPostNotification = functions.database.ref('/post/').onCreate(event => {

  const uuid = event.params.uid;

  console.log('User to send notification', uuid);

  var ref = admin.database.ref('Users/${uuid}/token');

  return ref.once("value", function(snapshot){
    
    const payload = {
        notification: {
            title: 'You have been invited to a trip.',
            body: 'Tap here to check it out!'
        }
    };
    
    admin.messaging().sendToDevice(snapshot.val(), payload);

  }, function (errorObject) {
      console.log("The read failed: " + errorObject.code);
  });

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

            var body = JSON.parse(body);
            console.log("body: " + JSON.stringify(body));
            
            var data = body["data"];
            console.log("data: " + JSON.stringify(data)); 
            
            var smsid = data["sms_id"]; 
                       
            console.log("smsid: " + smsid);

            var userRef = firestore.collection("users").doc(userId);
            return userRef.update({
              smsId: smsid
            })
            .then(function() {
                res.send(body); 
            })
            .catch(function(e) {                
                console.error("Error updating document: ", e);
                res.send(e);
            });
            
            
        } else {

            var _error = JSON.parse(error);

            res.send(_error);
        }
    });  

}); 

exports.publish = functions.https.onRequest((request, response) => {
  
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Credentials', 'true'); // vital

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

              response.send(true); 

              headless.dispose();
              
            }).catch(function(error) {
              
              response.send(false);               

              headless.dispose();

            });

          });

      });    
  }   
});


 