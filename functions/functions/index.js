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

  // Runs before every route. Launches headless Chrome.
  app.all('*', async (req, res, next) => {
      // Note: --no-sandbox is required in this env.
      // Could also launch chrome and reuse the instance
      // using puppeteer.connect()
      res.locals.browser = await puppeteer.launch({
        args: ['--no-sandbox']
      });
      next(); // pass control to next route.
  }); 
  
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
    isThumbnail = (customMetadata.thumbnail == 'true');
    var customMetadataType = parseInt(customMetadata.type);       

    // Cloud Storage files.
    const bucket = admin.storage().bucket(object.bucket);
    const config = {
      action: 'read',
      expires: '03-01-2500',
    };  

    if (isThumbnail == true) {    

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
      if (customMetadataType == 1) {  
    
        var _id = customMetadata.id;
        var _collection = customMetadata.collection; 
        let _time = admin.firestore.FieldValue.serverTimestamp();
        await firestore.collection(_collection).doc(_id).update({thumbnailSmallUrl: thumbFileUrl, timeStamp:_time});
    
      //Save User Thumbnail
      } else if (customMetadataType == 2) {  

        const fileUrl = originalResult[0];    
        var userId = customMetadata.userId;           
        
        let _time = admin.firestore.FieldValue.serverTimestamp();     
        
        await firestore.collection("users").doc(userId).update(
        { 
            profilePictureURL : fileUrl,
            thumbnailPictureURL: thumbFileUrl, 
            profilePicture : filePath,
            thumbnailPicture : thumbFilePath,          
            last_update:_time
        });

      // Update content  
      } else if (customMetadataType == 3) {  

          const fileUrl = originalResult[0];            
          var _short = customMetadata.short;          
          var _id = customMetadata.id;    
          let _time = admin.firestore.FieldValue.serverTimestamp();             

          await firestore.collection('contents')
          .doc(_short)
          .collection("collection")
          .doc(_id)
          .update({ 
            storage_icon_ref : filePath,
            storage_thumbFile_ref : thumbFilePath,
            icon_original : fileUrl,
            icon: thumbFileUrl, 
            last_update: _time 
          });                     
      
        // Save Media thumbnail image and video  
        } else if (customMetadataType == 4) {  

          var documentId = customMetadata.documentId;
          var doc_name_title = customMetadata.doc_name_title;
          var title = customMetadata.title;
          var desc = customMetadata.desc; 
          var userId = customMetadata.userId;              
          
          let _time = admin.firestore.FieldValue.serverTimestamp();    

          const fileUrl = originalResult[0]; 

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
          });    
      
        // Udate user avatar
        } else if (customMetadataType == 5) {  

          const fileUrl = originalResult[0];    
          var userId = customMetadata.userId; 
          var profilePictureToDelete = customMetadata.profilePictureToDelete;         
          var thumbnailPictureToDelete = customMetadata.thumbnailPictureToDelete;           

          let _time = admin.firestore.FieldValue.serverTimestamp();

          firestore.collection("users").doc(userId).update(
          { 
              "profilePictureURL" : fileUrl,
              "thumbnailPictureURL": thumbFileUrl, 
              "profilePicture" : filePath,
              "thumbnailPicture" : thumbFilePath,          
              "last_update" :_time
          });

          //Borra imagenes viejas. 
          bucket.file(profilePictureToDelete).delete();
          bucket.file(thumbnailPictureToDelete).delete();

      // Notification
      } else if (customMetadataType == 6) { 

          const fileUrl = originalResult[0];             
          var notificationId = customMetadata.notificationId;        

          //console.log("::notificationId:: " + notificationId);         

          let _time = admin.firestore.FieldValue.serverTimestamp();              

          firestore.collection("notifications").doc(notificationId).update(
          { 
              "imageURL" : fileUrl,
              "thumbnailImageURL": thumbFileUrl,               
              "last_update" :_time
          });
        
      }
      
    }  else { // not isThiumbnail

      //console.log("::customMetadataType:: " + customMetadataType);  

      if (customMetadataType == 1) {         
        
        const file = object.name;
        const thumbFileExt       = 'jpg';
        const fileDir = path.dirname(filePath);
        //const fileName = path.basename(filePath);

        const fileInfo = parseName(file);

        const thumbFilePath = path.normalize(path.join(fileDir, `${fileInfo.name}-thumbnail.${thumbFileExt}`));
        const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);
        const tempLocalDir       = path.join(os.tmpdir(), fileDir);
      
        await mkdirp(tempLocalDir);
        console.log("tempLocalThumbFile:: " + tempLocalThumbFile);
        const videoFile = bucket.file(file);
        const signedVideoUrl = await videoFile.getSignedUrl(config);             
        const videoUrl = signedVideoUrl[0];        
        console.log("videoUrl:: " + videoUrl);        
        await spawn(ffmpegPath, ['-ss', '0', '-i', videoUrl, '-f', 'image2', '-vframes', '1', '-vf', `scale=${THUMB_MAX_WIDTH}:-1`, tempLocalThumbFile]);
        await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath});      
        await fs.unlinkSync(tempLocalThumbFile);   

        var documentId = customMetadata.documentId;
        var doc_name_title = customMetadata.doc_name_title;
        var title = customMetadata.title;
        var desc = customMetadata.desc; 
        var userId = customMetadata.userId;              
        
        let _time = admin.firestore.FieldValue.serverTimestamp();            
        const fileThumb = bucket.file(thumbFilePath);
        
        // Get the Signed URLs for the thumbnail and original image.
        const signedUrl = await fileThumb.getSignedUrl(config);
        const thumbResult = signedUrl[0];

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
          });
      
      }
    }

    function parseName(fileName) {
        let _file = path.basename(fileName);
        var _name = _file.replace(/\.[^/.]+$/, "");      
        return { name : _name };
    } 

  });

  exports.sendNotification = functions.firestore
    .document('notifications/{notificationsId}')
    .onWrite((change, context) => {    

    const newValue = change.after.data();       
    var thumbnailImageURL = newValue.thumbnailImageURL;

    console.log("thumbnailImageURL " + thumbnailImageURL);

    if (thumbnailImageURL != undefined) {

      var title = newValue.title;
      var message = newValue.notification;
      var urlimage = newValue.thumbnailImageURL;
      var notificationId = context.params.notificationsId;
      var document_path = "notifications/" + notificationId + "/user-token-chat";
      
      console.log("document_path " + document_path);

      return firestore.collection(document_path).get()      
      .then(function(usersSnapshot) {
          
          usersSnapshot.forEach(function(docUserNotification) {
            var notiData = docUserNotification.data();   
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
            admin.messaging().sendToDevice(token, payload);     

          });    
      
      }).catch(err=>{
        console.log("error:  " + err);
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


  exports.getClassBuckup = functions.https.onRequest((req, res) => {       

        const collection = req.body.collections; //['languages', 'roles'];        
    
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
            
            Promise.all(promises).then(process.exit);

            let _collJson = JSON.stringify(promises);

            res.send(_collJson); 

        } catch (err) {
            console.error(err)
        }       

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
                let json_resutl_ok = { data: { html: _html, result: true }};
                response.send(json_resutl_ok); 
                headless.dispose();
                
              }).catch(function(error) {

                let json_resutl_false = { data: { result: false }};                
                response.send(json_resutl_false);               
                headless.dispose();

              });

            });

        });    
    }   

  });

  app.get('/contenido', async function screenshotHandler(req, res) {

    const url = req.query.url;    

    return firestore.collection(document_path).get()      
    .then(function(usersSnapshot) {
        
        /*usersSnapshot.forEach(function(docUserNotification) {
          var notiData = docUserNotification.data();   
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
          admin.messaging().sendToDevice(token, payload);     

        });*/
    
        res.status(500).send(e.toString());

    }).catch(err=>{
      console.log("error:  " + err);
    });  

  });

    // Handler to take screenshots of a URL.
  app.get('/screenshot', async function screenshotHandler(req, res) {
      const url = req.query.url;
      if (!url) {
      return res.status(400).send(
          'Please provide a URL. Example: ?url=https://google.com');
      }
      const browser = res.locals.browser;
      try {
      const page = await browser.newPage();
      await page.goto(url, {waitUntil: 'networkidle2'});
      const buffer = await page.screenshot({fullPage: true});
      res.type('image/png').send(buffer);
      } catch (e) {
      res.status(500).send(e.toString());
      }
      await browser.close();
  });
  // Handler that prints the version of headless Chrome being used.
  app.get('/version', async function versionHandler(req, res) {
      const browser = res.locals.browser;
      res.status(200).send(await browser.version());
      await browser.close();
  });
  const opts = {memory: '2GB', timeoutSeconds: 60};
  exports.screenshot = functions.runWith(opts).https.onRequest(app);
  exports.version = functions.https.onRequest(app);


  function buildHtmlWithPost (post) {
    const string = '<!DOCTYPE html><head>' +
      '<title>' + post.title + ' | Example Website</title>' +
      '<meta property="og:title" content="' + post.title + '">' +
      '<meta property="twitter:title" content="' + post.title + '">' +
      '<link rel="icon" href="https://example.com/favicon.png">' +
      '</head><body>' +
      '<script>window.location="https://example.com/?post=' + post.id + '";</script>' +
      '</body></html>';
    return string;
  }
  
  exports.buildHtmlWithContent = function(req, res) {
    const path = req.path.split('/');
    const postId = path[2];
    admin.database().ref('/posts').child(postId).once('value').then(snapshot => {
      const post = snapshot.val();
      post.id = snapshot.key;
      const htmlString = buildHtmlWithPost(post);
      res.status(200).end(htmlString);
    });
  };


  
