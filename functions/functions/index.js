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
const admin = require('firebase-admin');
var serviceAccount = require("./key/curupas-backen-firebase-adminsdk-b7mbc-613c592d37.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://curupas-backen.firebaseio.com"
});
const mkdirp = require('mkdirp-promise');
const db = admin.firestore();
//const rp = require('request-promise');
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

    //Save Post Thumbnail
    if (customMetadataType == 1) {  
   
      var postId = customMetadata.postId;
      console.log('postId: '+ postId);          
      let _time = admin.firestore.FieldValue.serverTimestamp();
      console.log("_time: " + _time);
      await db.collection("posts").doc(postId).update({thumbnailSmallUrl: thumbFileUrl, timeStamp:_time});
   
    //Save User Thumbnail
    } else if (customMetadataType == 2) {  

      const fileUrl = originalResult[0];    
      var userId = customMetadata.userId;
      var year = customMetadata.year;
      console.log('year: '+ year);          
      let _time = admin.firestore.FieldValue.serverTimestamp();
      console.log("_time: " + _time);
      await db.collection("users").doc(userId).update(
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

  var ref = admin.database().ref('Users/${uuid}/token');

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

  function callback(error, response, body) {      
      //if (!error && response.statusCode == 200) {
      //    console.log(body);
      //}
      if (!error) {

        var sms_id = body.data.sms_id;         
        
        db.collection("users").doc(userId).update({smsId: sms_id})
        
      } 
  }

  request(options, callback);
 

  /*console.log("phone: " + phone);
  console.log("payload: " + payload);

  const postBody = { 
    recipient: parseInt(phone),
    message: payload 
  };

  console.log("postBody: " + JSON.stringify(postBody));

  const options = {
    url: 'https://api.notimation.com/api/v1/sms',
    headers: {
        'Content-Type' : 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 7FA7ED241142E7BE36671CE0FEC9E84F'
    },
    json: true,
    body: postBody
  };
 
   
  console.log("options: " + JSON.stringify(options));

  rp(options)
    .then(response => {
      
      console.log('Good response: ' + JSON.stringify(response.data));
      
      res.send({
        smresponses_id : response.data.sms_id, 
        response : response.data.sms_status
      });

    })
    .catch(err => {
      // API call failed...
      res.status(500).send(err);
    });*/
    
});

/*exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send({
      "data": {
          "message": `Hello, ${request.body.data.name}!`
      }
  });
});*/