    //'use strict';
   
    functions = require('firebase-functions');
    admin = require('firebase-admin');
    firebase = require('firebase');  
    var firestoreService = require('firestore-export-import');  

    //const Firepad  = require('firepad');
    const jsdom = require("jsdom");
    const { JSDOM } = jsdom;
    
    const cors  = require('cors')({ origin: true });
    var path    = require('path');       
    var fs      = require('fs'); 
    const os    = require('os');

    const mkdirp  = require('mkdirp-promise');
    const request = require('request');
    const spawn   = require('child-process-promise').spawn;

    const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path; 

    const express = require('express');
    var engines   = require('consolidate');
      
    serviceAccount = require("./key/curupas-app-firebase-adminsdk-5t7xp-cb5f62c82a.json");
    db_url = "https://curupas-app.firebaseio.com";

    var TOKEN_PATH;
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: db_url
    });

    firestoreService.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: db_url,        
    });
    
    firestore = admin.firestore(); 

    const firebaseConfig = {
      apiKey: "AIzaSyCdPIxQCyCbUMCYfcDErZLPMZtPOs1-mbQ",
      authDomain: "curupas-app.firebaseapp.com",
      databaseURL: "https://curupas-app.firebaseio.com",
      projectId: "curupas-app",
      storageBucket: "curupas-app.appspot.com",
      messagingSenderId: "813267916846",
      appId: "1:813267916846:web:f1780b6ac9f8079baa67bf",
      measurementId: "G-NK6KP62FLM"
    };
    firebase.initializeApp(firebaseConfig);  

    //streaming
    exports.streaming = require("./streaming");
    exports.share     = require("./share");
    
    var OPTION_SHARE  = 'share';            
    var OPTION_OAUTH2CALLBACK  = 'oauth2callback';              

    const app = express();
    app.engine('html', engines.hogan); 
    app.set('views', path.join(__dirname, 'views'));    
    app.use(cors);     
      
    app.get('*', (req, res) => {
        
      console.log("<<<<<<<<<<<<<<<<<<<<======================");

      console.log("req.path:", req.path); 
      
      var pathParam = req.path.split('/')[1];

      console.log("pathParam:" + pathParam);   
      
      if ( pathParam === 'favicon.ico' ) {
        res.status(204).end();
        return;
      }
       
      var url = req.url;
      var urlParams;
      
      if (url.indexOf('?') !== -1) {
        let params = url.split("?");
        urlParams = getJsonFromUrl(params[1]);        
      }     

      var static_url;   

     if ( pathParam === OPTION_OAUTH2CALLBACK ) {       
        
        console.log(OPTION_OAUTH2CALLBACK + " : " + JSON.stringify(urlParams));

        var _time =  new Date();

        firestore.collection("control").doc("streaming").set({ 
          code: urlParams.ode,
          scope: urlParams.scope,            
          fetch_code_trigger: false,        
          last_update: _time 
        },{ merge: true }).catch((error) => {
          console.log('Error setting collection:', error);
          return error;
        });

        res.status(200).send(true);        

      } else if ( pathParam === OPTION_SHARE ) {    

        var document = req.path.split('/')[1];
        
        const userAgent = req.headers['user-agent'].toLowerCase();

        let views = path.join(__dirname, 'views');      
        let indexHTML = fs.readFileSync(views + '/share.html').toString();     

        let appPath = "share/" + document;
        console.log("document: " + document);

        firestore.doc(appPath)
        .get().then(document => {
                        
              var ogPlaceholder = '<meta name="functions-insert-dynamic-og">';          
              var DesignAppIdPlaceholder = "<functions-path-design-app-id>";       

              var document_path = document.data().document_path;

              firestore.doc(document_path)
              .get().then(document => {

                  let description = document.data().description;
                  let icon_original = document.data().icon_original;
                  let name = document.data().name;

                  let html_meta = getOpenGraph(icon_original, description, name);

                  console.log(html_meta);               
                  
                  indexHTML = indexHTML.replace(ogPlaceholder, html_meta);
                  indexHTML = indexHTML.replace(DesignAppIdPlaceholder, document_path);         

                  res.status(200).send(indexHTML);    
                  
                  return indexHTML;

                }).catch((error) => {
                  console.log("error: " + error);
                  return error;
          
                }); 

                return document_path;

        }).catch((error) => {
          console.log("error: " + error);
          return error;

        });     

      } else {         

          //urlParams

        if (urlParams) {
          return res.render(static_url, urlParams); 
        } else {
          return res.render(static_url); 
        }

      }

      function getJsonFromUrl(url) {
        if (!url) url = location.search;
        var query = url.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
          var item = part.split("=");
          result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
      }
      
    });

    exports.app = functions.https.onRequest(app);

    // Max height and width of the thumbnail in pixels.
    const THUMB_MAX_HEIGHT = 200;
    const THUMB_MAX_WIDTH = 200;
    // Thumbnail prefix added to file names.
    const THUMB_PREFIX = 'thumb_'; 

    exports.thumbnail = functions.storage.object().onFinalize(async (object) => {  
      
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
        
        }
      }

      function parseName(fileName) {
          let _file = path.basename(fileName);
          let _name = _file.replace(/\.[^/.]+$/, "");      
          return { name : _name };
      } 

    });

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

    exports.sms = functions.https.onRequest((req, res) => {
      
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
    
    exports.backup = functions.https.onRequest((request, response) => {  

      let _collection = request.body.collection;   

      console.log(_collection);
      
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

            try {

              firestoreService
              .backup(_collection)
              .then(data => {  
                response.status(200).send(data);        
                return data;           
              }).catch((error) => {                
                console.log('Error getting sertvice backup');
                return error;
              });  
              
            } catch (e) {
                console.error(e);
                return e;
            } 

          }

      } catch (e) {
        console.error(e);
        return e;
      }      
     

    });     

    /*exports.publish = functions.https.onRequest((request, response) => {
      
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

    });*/

    exports.build = functions.https.onRequest((req, res) => {     

        console.log("req.path:", req.path); 
        const pathParams = req.path.split('/');

        switch (pathParams[1]) {
          case "newsletter": {
            let newId = pathParams[2];   
            getNewsletterHtmlById(newId, res);
            break;
          } 
          /*case "historia":
            break;
          case "pumas":
            break;
          case "valores":
            break;
          case "calendario": 
            break;       
          case "post":
            break;
          case "camada":
            break;*/       
        }   
        
        function getNewsletterHtmlById(newsletterId, res) {        
                
          if (!newsletterId) {
            return res.status(400).send('No se encontro el Id');
          }             

          ///contents/newsletter/collection/68WFqTnqqHyMWeH9iGsn

          return firestore.collection("contents")
            .doc("newsletter").collection("collection")
            .doc(newsletterId).get().then( (document) => {        

                
            if (document.exists) {

              let docId = document.id;
              let name = document.data().name;
              //let mensaje = document.data().message;
              //let contact = document.data().contact;
              let preview_image = document.data().preview_image;          
              let title = "Mensaje para " + name;
              const htmlString = buildHTMLForPage(docId, title, name, preview_image);

              console.log("_________________________");
              console.log(htmlString);
              
              return res.status(200).send(htmlString);
            
            } else {
              return res.status(403).send("Document do not exit");
            }        

          }).catch((error) => {    
              console.log("Error getting document:", error);
              return res.status(404).send(error);
          });

        }

        function buildHTMLForPage (docId, title, nombre, image) {
        
          //let _style = buildStyle();
          //let _body = buildBody(nombre, mensaje, contacto);        
          
          var _html = '<!DOCTYPE html><head>' +          
          '<meta property="og:title" content="' + nombre + '">' +                    
          '<meta property="og:image" content="' + image + '"/>' +
          '<title>' + title + '</title>';        
          
          //'<link rel="icon" href="https://noti.ms/favicon.png">' +
          //'<style>' + _style  + '</style>' +
          //'</head><body>' + _body + '</body></html>';

          let _javascript = `<!DOCTYPE html><head><meta property="og:title" content="Jose Vigil"><meta property="og:image" content="https://storage.googleapis.com/notims.appspot.com/cobranzas/sipef/43YjVa_5205172.png?GoogleAccessId=notims%40appspot.gserviceaccount.com&Expires=16730323200&Signature=jbrD3iGC%2FbVaHDcfyUS2ipgfmpc2Czdi6ePG8HdcFmcMZ%2F3WaIpHUN%2BSWXU9tMOJfOm6aSJDfJPrQpXb5B9gzTzzrITXYRRElbLF1bJGtIzGbh48G9018DepMHWgEFzY6hTrGjFGuK9GPFBBu0FruHHYJgxRcEhnBGosJshOUCsddvVR%2Bh8eVvLJlMgMMaAV%2F2Aam0Z9MnUIFUDACX19NFqCEReiy1gFiWTLM15iyvoegQNgCwzX67dAKQfyfI3MeCQDvEDYKiP6Nbpgz%2F0oZOxl7XbvUQxToUc41R2sw%2FtFf8w3qh3uXUa%2FNijO5h7iiWunw98Y0FU%2Bjb5rw%2FRN6Q%3D%3D"/><title>Mensaje para Jose Vigil</title><script src="https://code.jquery.com/jquery-3.5.1.min.js"></script><script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-app.js"></script><script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-firestore.js"></script><script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-functions.js"></script><script>$(document).ready(function(){console.log("ENTRAAAAAA");const e={apiKey:"AIzaSyAM4WQDHpHh1oRT_v-6ikquE4V809hA3kY",authDomain:"notims.firebaseapp.com",databaseURL:"https://notims.firebaseio.com",projectId:"notims",storageBucket:"notims.appspot.com",messagingSenderId:"79471870593",appId:"1:79471870593:web:ef29a72e1b1866b2bb4380",measurementId:"G-8T5N81L78J"};return firebase.initializeApp(e),firebase.firestore().collection("cobranzas").doc(` + docId + `).get().then(e=>{if(console.log("____1____"),e.exists){var o=0;if(console.log("____2____"),e.data().previewed){o=parseInt(e.data().previewed)+1}else o++;e.ref.update({previewed:o}).then(e=>(console.log("____3____"),e.id)).catch(e=>{console.log("Error saving preview "+e)})}return e.id}).then(e=>(console.log("____4____"),e.id)).catch(e=>(console.log("Error getting document:",e),res.status(404).send(e)))});</script></head>`;
          var _script;                
          _script =  `<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>`;
          _script += `<script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-app.js"></script>`;
          _script += `<script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-firestore.js"></script>`;        
          _script += `<script src="https://www.gstatic.com/firebasejs/7.2.1/firebase-functions.js"></script>`;  
          _script += `<script>${_javascript}</script>`;
          _html = _html + _script + '</head>';
          
          return _html;
        } 

      });


      //var authClient = require("./key/client_secret_813267916846-on33ikhqtg73ki6upcs6d3la2sjiof77.apps.googleusercontent.com.json");
      //const CREDENTIALS = readJson(`${__dirname}/key/client_secret_813267916846-on33ikhqtg73ki6upcs6d3la2sjiof77.apps.googleusercontent.com.json`);

      /*const {google} = require('googleapis');    
      const {authenticate} = require('@google-cloud/local-auth');
      const urlParse = require('url-parse');
      const queryParse = require('query-string'); 
      const bodyParser = require('body-parser');
      const axios = requier('axios'); 

      exports.auth = functions.https.onRequest((req, res) => {
      
      });*/