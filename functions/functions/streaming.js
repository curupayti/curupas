
  
  var rp = require("request-promise");
  var path = require('path');
  var fs = require('fs'); 

  //const functions = require('firebase-functions');
  var readline = require('readline');
  var {google} = require('googleapis');
  var OAuth2 = google.auth.OAuth2;    
  
  exports.control = functions.firestore
    .document('control/streaming')
    .onUpdate( async (change, context) => { 

      //https://developers.google.com/youtube/v3/quickstart/nodejs

      //https://stackoverflow.com/questions/63444245/typeerror-cannot-read-property-redirect-uris-of-undefined-youtube-data-api-au
      //https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCeLNPJoPAio9rT2GAdXDVmw&key=AIzaSyCC9bDy5SitFtyT0A0SIryxOQuXmfxR3bk

      /*
      curl \
      'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=UUwB4tpXCMWi-bw5HpMlY6Bg&key=[YOUR_API_KEY]' \
      --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
      --header 'Accept: application/json' \
      --compressed  
      */

      var newValue = change.after.data();       
      let fetch_code_trigger    = newValue.fetch_code_trigger;     
      let fetch_token_trigger   = newValue.fetch_token_trigger;
      let get_playlists         = newValue.get_playlists;
      var expiry_date;
      if (newValue.tokens) {
              expiry_date = newValue.tokens.expiry_date;    
      }
      var token_expiry_date_stored = newValue.token_expiry_date_stored;

      console.log("fetch_code_trigger: " + fetch_code_trigger);
      console.log("fetch_token_trigger: " + fetch_token_trigger);
      console.log("get_playlists: " + get_playlists);

      var client_secret = path.join(__dirname, '/key/client_secret.json');
      var code = newValue.code; 

      if ( fetch_token_trigger || get_playlists ) {   
        
        fs.readFile(client_secret, async function processClientSecrets(err, content) {
          
          if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
          }

          let credentials = JSON.parse(content);
        
          let clientSecret = credentials.web.client_secret;
          let clientId = credentials.web.client_id;
          let redirectUrl = credentials.web.redirect_uris[0];
          var oauth2Client = new OAuth2(clientId, clientSecret, redirectUrl);        

          console.log("code: " + code);

          if (fetch_token_trigger)  {
          
            try {

                const _tokens = await oauth2Client.getToken(code);

                //var tokens = JSON.stringify(_tokens);
                //console.log("tokens: " + JSON.stringify(tokens));

                var _time =  new Date();

                firestore.collection("control").doc("streaming").set({ 
                  tokens: _tokens.tokens,
                  fetch_token_trigger: false,
                  last_update: _time 
                },{ merge: true }).catch((error) => {
                  console.log('Error setting collection:', error);
                  return error;
                });

            } catch (error) {

              console.log("errror: " + JSON.stringify(error));

            }

          /*} else if (get_playlists)  {

            try {                       

              console.log(">>>>>>>>>>>>>>>>>>>> POST <<<<<<<<<<<<<<<<<<<<<<<<");

              var accessToken = newValue.tokens.access_token;

              console.log("accessToken: " + accessToken);

              var APIURL = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCeLNPJoPAio9rT2GAdXDVmw";

              var options = {
                  method: "GET",
                  url: APIURL,
                  headers: {
                      'Content-Type': 'application/json',
                      'Connection': 'Keep-Alive',
                      'Authorization': 'Bearer ' + accessToken
                  }
              };                    

              console.log(JSON.stringify(options));

              var resutl_playlist = [];
      
              rp(options)              
              .then(async function (results_playlist) {  

                const playlistPromise = await new Promise(async (resolve, reject) => {

                    var promise_playlist = []; 

                    var restul = JSON.parse(results_playlist);            

                    console.log(
                        " ------ restul ------- " + JSON.stringify(restul)
                    );

                    let lenght = restul.items.length;                 

                    console.log("length: " + lenght); 

                    let count = 0;                                                      

                    for (var i=0; i<lenght; i++) {                      

                        var item = restul.items[i];

                        var id = item["id"];
                        var etag = item["etag"];

                        console.log("id: " + id);
                        console.log("etag: " + etag);

                        var snippet = item.snippet;

                        var channelId = snippet["channelId"];
                        var title = snippet["title"];

                        var thumbnails = snippet.thumbnails;

                        let defaul = thumbnails.default;

                        let thumbnail_height = defaul.height;
                        let thumbnail_width = defaul.width;
                        let thumbnail_url = defaul.url;

                        var _time =  new Date();
                        
                        var json = {
                          id:id, 
                          etag:etag,
                          channelId:channelId,
                          title:title,
                          thumbnails:thumbnails,
                          thumbnail_height:thumbnail_height,
                          thumbnail_width:thumbnail_width,
                          thumbnail_url:thumbnail_url,
                          last_update:_time                            
                        };        

                        console.log(
                            " ------ json ------- " + JSON.stringify(json)
                        ); 

                        promise_playlist.push(
                          firestore.collection("media").doc(id).set(json,{merge:true})
                        );

                        resutl_playlist.push(json);                                                  

                        if (count === (lenght-1)) {                                                   
                            resolve(promise_playlist);
                        }

                        count++;
                    } 

                   });  

                  return playlistPromise;                 

              })
              .then(async (resutls) => {

                //const videosPromise = new Promise(async (resolve, reject) => {

                  console.log("PASAAAAAAA");

                  let lenght = resutl_playlist.length;

                  var ps = [];

                  for (var i=0; i<lenght; i++) {

                      var json = resutl_playlist[i];

                      var id          = json.id;                  

                      var APIURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=" + id;

                      var options = {
                          method: "GET",
                          url: APIURL,
                          headers: {
                              'Content-Type': 'application/json',
                              'Connection': 'Keep-Alive',
                              'Authorization': 'Bearer ' + accessToken
                          } 
                      };

                      ps.push(rp(options));                   

                  }   

                  console.log("FINALLLLLLL");
                  //console.log("ps: " + JSON.stringify(ps) );

                  return Promise.all(ps);

             })
             .then(async (results_promise_videos) => {  

                  console.log("LLEGAAAAAAAAA");

                  var promise_videos = [];                                                           

                  //let videosJsonString = "[" + JSON.stringify(results_promise_videos) + "]";

                  //var videos = JSON.parse(results_promise_videos);

                  //console.log(
                  //    "******** videos ******* " + JSON.stringify(videos)
                  //); 

                  //var length_videos = videos.length;
                  //var count = 0;

                  console.log(
                      " ------ results_promise_videos ------- " + results_promise_videos
                  );

                  //if (length_videos>0) {                

                     //results_promises_videos = await results_promises_videos_json.forEach(async (result) => {                      
                   
                      
                    //for (var i=0; i<length_videos; i++) {                      

                      var videos  = results_promise_videos;

                      let items = videos.items;

                      let lenght = items.length;

                      console.log(
                          " ------ lenght ------- " + lenght
                      );

                      for (var j=0; j<lenght; j++) {

                          let item = items[j];

                          var id          = item.id;                      
                          var etag        = item.etag;

                          var snippet     = item.snippet;                      

                          var title       = snippet.title;
                          var channelId   = snippet.channelId;                      
                          var description = snippet.description;                      
                          var position    = snippet.position;                      

                          console.log("title: " + title);
                          console.log("channelId: " + channelId);

                          var channelTitle= snippet.channelTitle;                      
                          var playlistId  = snippet.playlistId;                      

                          var resourceId  = snippet.resourceId;
                          var videoId     = resourceId.videoId;

                          var thumbs  = snippet.thumbnails;  

                          console.log("thumbs: " + JSON.stringify(thumbs));

                          let defau = JSON.stringify(thumbs.default);

                          let defauJson = JSON.parse(defau);

                          console.log("defauJson: " + JSON.stringify(defauJson));

                          var thumbnail_height = defauJson.height;
                          var thumbnail_width = defauJson.width;
                          var thumbnail_url = defauJson.url;                   

                          var _time =  new Date();

                          var _json = {  
                            id:videoId, 
                            etag:etag,                        
                            title:title,
                            channelId:channelId,
                            description:description,
                            position:position,                                                
                            channelTitle:channelTitle,
                            playlistId:playlistId,                             
                            thumbnails:thumbs,
                            thumbnail_height:thumbnail_height,
                            thumbnail_width:thumbnail_width,
                            thumbnail_url:thumbnail_url,
                            last_update:_time                            
                          };                                                 

                          promise_videos.push(
                            firestore.collection("media").doc(playlistId).collection("videos").add(_json)
                          );  

                      }

                      //if (count === (length_playlists-1)) {    
                      //    console.log("LLLEEEEGGAAAAAAAAAAAAAAA");                                               
                      //   return promise_videos;
                      //}

                      //count++;

                    //});                                              
                    //}

                  //}       
                  console.log("MAAAAALLLLLL");     
                  return Promise.all(promise_videos);         


              }).then(async (finalresults) => {

                var _time =  new Date();

                return firestore.collection("control").doc("streaming").set({                   
                  get_playlists: false,
                  last_update: _time 
                },{ merge: true });
                
              })                
              .catch(function (err) {
                  console.log("error: " + err );
              });                     
             

            } catch (error) {

              console.log("errror: " + JSON.stringify(error));

            }

          }

        });

      }*/

      } else if (get_playlists)  {

                                  

              console.log(">>>>>>>>>>>>>>>>>>>> POST <<<<<<<<<<<<<<<<<<<<<<<<");

              var accessToken = newValue.tokens.access_token;

              console.log("accessToken: " + accessToken);

              var APIURL = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=UCeLNPJoPAio9rT2GAdXDVmw";

              var options = {
                  method: "GET",
                  url: APIURL,
                  headers: {
                      'Content-Type': 'application/json',
                       'Authorization': 'Bearer ' + accessToken
                  }
              };                    

              console.log(JSON.stringify(options));

              var resutl_playlist = [];
      
              rp(options)              
              .then(async function (results_playlist) {   

                  var restul = JSON.parse(results_playlist);            

                  console.log(
                      " ------ restul ------- " + JSON.stringify(restul)
                  );

                  let lenght = restul.items.length;                 

                  console.log("length: " + lenght); 

                  //let count = 0; 

                  var promise_playlist = [];                                  

                  for (var i=0; i<lenght; i++) {                      

                      var item = restul.items[i];

                      var id = item["id"];
                      var etag = item["etag"];

                      console.log("id: " + id);
                      console.log("etag: " + etag);

                      var snippet = item.snippet;

                      var channelId = snippet["channelId"];
                      var title = snippet["title"];

                      var thumbnails = snippet.thumbnails;

                      var _time =  new Date();
                      
                      var json = {
                        id:id, 
                        etag:etag,
                        channelId:channelId,
                        title:title,
                        thumbnails:thumbnails,
                        last_update:_time                            
                      };        

                      console.log(
                          " ------ json ------- " + JSON.stringify(json)
                      ); 

                      promise_playlist.push(
                        firestore.collection("media").doc(id).set(json,{merge:true})
                      );

                      resutl_playlist.push(json);                                                  

                      //if (count == (lenght-1)) {                                                   
                      //    return promise_playlist;
                      //}

                      //count++;
                  }  

                  return promise_playlist;             
                  

              })
              .then(async (resutls) => {

                let lenght = resutl_playlist.length;

                var ps = [];

                for (var i=0; i<lenght; i++) {

                    var json = resutl_playlist[i];

                    var id          = json.id;                  

                    var APIURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=" + id;

                    var options = {
                        method: "GET",
                        url: APIURL,
                        headers: {
                            'Content-Type': 'application/json',
                             'Authorization': 'Bearer ' + accessToken
                        } 
                    };

                    ps.push(rp(options));                   

                }   

                return await Promise.all(ps);

              })
              .then(async (results_promise_videos) => {             

                  var json_videos = [];  

                  //var resutl_promises_videos = await Promise.all(ps)
                  //.then((results_promise_videos) => {                                      

                  //fs.writeFileSync('results_promise_videos.json', results_promise_videos);                                  

                  results_promise_videos = "[" + results_promise_videos + "]";

                  var results = JSON.parse(results_promise_videos);

                  console.log(
                      "******** results ******* " + JSON.stringify(results)
                  ); 

                  var length_playlists = results.length;
                  var count = 0;

                  console.log(
                      " ------ length_playlists ------- " + length_playlists
                  );

                  var promise_videos = [];  

                  if (length_playlists>0) {                

                    results.forEach(async (result) => {                      
                      
                      var items       = result.items;

                      let lenght = items.length;

                      for (var i=0; i<lenght; i++) {

                          let item = items[i];

                          var id          = item.id;                      
                          var etag        = item.etag;

                          var snippet     = item.snippet;                      

                          var title       = snippet.title;
                          var channelId   = snippet.channelId;                      
                          var description = snippet.description;                      
                          var position    = snippet.position;                      

                          console.log("title: " + title);
                          console.log("channelId: " + channelId);

                          var channelTitle= snippet.channelTitle;                      
                          var playlistId  = snippet.playlistId;                      

                          var resourceId  = snippet.resourceId;
                          var videoId     = resourceId.videoId;

                          var thumbnails  = snippet.thumbnails;                      

                          var _time =  new Date();

                          var _json = {  
                            id:videoId, 
                            etag:etag,                        
                            title:title,
                            channelId:channelId,
                            description:description,
                            position:position,                                                
                            channelTitle:channelTitle,
                            playlistId:playlistId,                            
                            //videoId:videoId,
                            thumbnails:thumbnails,
                            last_update:_time                            
                          };                        

                          json_videos.push(JSON.stringify(_json));

                          promise_videos.push(
                            firestore.collection("media").doc(playlistId).collection("videos").add(_json)
                          );  

                        }

                        if (count === (length_playlists-1)) {                                                   
                            return promise_videos;
                        }

                        count++;

                    });

                  }

                  return resutl_promises_videos;

                }).then(async (finalresults) => {

                  var _time =  new Date();

                  return firestore.collection("control").doc("streaming").set({                   
                    get_playlists: false,
                    last_update: _time 
                  },{ merge: true });
                  
                })                
                .catch(function (err) {
                    console.log("error: " + err );
                });                        
             

          }

        });

      }

      
      if ( fetch_code_trigger ) {        
        
        var TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH ||
            process.env.USERPROFILE) + '/.credentials/';
        TOKEN_PATH = TOKEN_DIR + 'youtube-nodejs-quickstart.json';        
        fs.readFile(client_secret, function processClientSecrets(err, content) {
          if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
          }          
          authorize(JSON.parse(content));
        });       

      }         

      if ( expiry_date && (token_expiry_date_stored !== true)) {

        var d = new Date(expiry_date);
        var _time =  new Date();

        firestore.collection("control").doc("streaming").set({                   
          token_expiry_date: d,
          token_expiry_date_stored: true,
          last_update: _time 
        },{ merge: true });

      }   

      return newValue;

    }); 

    function authorize(credentials, callback) {
      
      let clientSecret = credentials.web.client_secret;
      let clientId = credentials.web.client_id;
      let redirectUrl = credentials.web.redirect_uris[0];
      var oauth2Client = new OAuth2(clientId, clientSecret, redirectUrl);

      // Check if we have previously stored a token.
      fs.readFile(TOKEN_PATH, function(err, token) {
        if (err) {
          getNewToken(oauth2Client, callback);
        } else {
          oauth2Client.credentials = JSON.parse(token);
          return callback(oauth2Client);
        }
      });
    }

    function getNewToken(oauth2Client, callback) {

      var authUrl = oauth2Client.generateAuthUrl({
        access_type: 'offline',
        prompt: 'consent',
        scope: 'https://www.googleapis.com/auth/youtube'
      });

      console.log('Saving url: ', authUrl);

      var _time =  new Date();
      //var base64 = Buffer.from(authUrl).toString('base64')

      firestore.collection("control").doc("streaming").set({ 
        url_authorization: authUrl, 
        fetch_code_trigger: false,                               
        last_update: _time 
      },{ merge: true }).catch((error) => {
        console.log('Error setting collection:', error);
        return error;
      });

    }