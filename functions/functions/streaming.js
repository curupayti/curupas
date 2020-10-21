
  
  var rp = require("request-promise");
  var path = require('path');
  var fs = require('fs'); 

  //const functions = require('firebase-functions');
  var readline = require('readline');
  var {google} = require('googleapis');
  var OAuth2 = google.auth.OAuth2;    

  exports.streamingFeed = functions.firestore
    .document('videos/playlist')
    .onUpdate( async (change, context) => { 

      var newValue = change.after.data();       
      let playlist    = newValue.collection();

      let lenght = playlist.length;                 

      console.log("length: " + lenght); 
      
      
      return newValue;

    }); 
  
  exports.streamingFeed = functions.firestore
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

          } else if (get_playlists)  {

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

                  let count = 0; 

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

                      if (count == (lenght-1)) {                                                   
                          return promise_playlist;
                      }

                      count++;
                  }               
                  

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

                var json_videos = [];  

                var resutl_promises_videos = await Promise.all(ps)
                .then((results_promise_videos) => {                                      

                  //fs.writeFileSync('results_promise_videos.json', results_promise_videos);                                  

                  results_promise_videos = "[" + results_promise_videos + "]";

                  var results = JSON.parse(results_promise_videos);

                  console.log(
                      "******** results ******* " + JSON.stringify(results)
                  ); 

                  var length = results.length;
                  var count = 0;

                  console.log(
                      " ------ length ------- " + length
                  );

                  var promise_videos = [];  

                  if (length>0) {                

                    results.forEach(async (result) => {
                      
                      var id          = result.id;                      
                      var etag        = result.etag;
                      var items       = result.items[0];

                      var snippet     = items.snippet;                      

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
                        description:description,
                        //videoId:videoId,
                        thumbnails:thumbnails,
                        last_update:_time                            
                      };                        

                      json_videos.push(JSON.stringify(_json));

                      promise_videos.push(
                        firestore.collection("media").doc(playlistId).collection("videos").add(_json)
                      );                      

                      if (count == (lenght-1)) {                                                   
                          return promise_videos;
                      }

                      count++;

                    });

                  }

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

              })                
              .catch(function (err) {
                console.log("error: " + err );
              });                
             

            } catch (error) {

              console.log("errror: " + JSON.stringify(error));

            }

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