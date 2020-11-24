
  
  var rp = require("request-promise");
  var path = require('path');
  var fs = require('fs'); 

  //const functions = require('firebase-functions');
  var readline = require('readline');
  var {google} = require('googleapis');
  var OAuth2 = google.auth.OAuth2;   

  exports.media = functions.runWith({ timeoutSeconds: 540 })
                  .https.onCall((data, context) => {       

      var _json = {};  

      try { 

          const result = new Promise(async (resolve, reject) => {     

              firestore.collection("media").get()
              .then(async (querySnapshotPlaylist) => {

                var playlistLength = querySnapshotPlaylist.size;
                var countPlaylist = 1;

                //console.log("playlistLength: " + playlistLength);

                querySnapshotPlaylist.forEach(async (docPlaylist) => {

                    let docp        = docPlaylist.data();
                    var idp         = docp.id;
                    var snippetp    = docp.snippet;   
                    let thumbnailsp = snippetp.thumbnails;                                    
                    var defaulp     = thumbnailsp.default;                                                                 

                    let title         = snippetp.title;
                    title = title.replace(/['"]+/g, '');

                    let description   = snippetp.description;
                    let channelTitle  = snippetp.channelTitle;
                    let channelId     = snippetp.channelId; 
                    let publishedAt   = snippetp.publishedAt;                            
                    let thumbnailp    = "";                            

                    if (defaulp) {
                      thumbnailp = defaulp.url; 
                    }                     

                    let j = `{                                                
                        "id":"${idp}", 
                        "title":"${title}", 
                        "description":"${description}", 
                        "channelTitle":"${channelTitle}", 
                        "channelId":"${channelId}", 
                        "thumbnail":"${thumbnailp}", 
                        "publishedAt":"${publishedAt}",
                        "videos":[]                      
                    }`;                    

                    var json = JSON.parse(j);
                    _json[idp] = json;                      

                    countPlaylist++; 

                    if ( countPlaylist === playlistLength ) {                                            

                      countPlaylist = 0;

                    }                 

                    firestore.collection("media").doc(idp).collection("videos").get()
                    .then(async (querySnapshotVideo) => {

                        var videosLength = querySnapshotVideo.size;
                        var countVideos = 1;  

                        //console.log("videosLength: " + videosLength);                                        

                        querySnapshotVideo.forEach(async (docVideo) => {

                          let docv        = docVideo.data();
                          var snippetv    = docv.snippet;    
                          let thumbnailsv = snippetv.thumbnails;
                          var defaulv     = thumbnailsv.default; 

                          let idv           = docv.id;
                          let title         = snippetv.title;
                          var description   = "";

                          if (snippetv.description) {
                              description = snippetv.description;
                          }

                          let channelId     = snippetv.channelId;                           
                          let position      = snippetv.position;                        

                          let videoId       = snippetv.resourceId.videoId;
                          let publishedAt   = snippetv.publishedAt;                            

                          let playlistId    = snippetv.playlistId;  
                          var thumbnailv    = "";

                          if (defaulv) {
                            thumbnailv = defaulv.url;
                          }

                          let j  = `{
                              "id":"${idv}", 
                              "title":"${title}", 
                              "description":"${description}",                               
                              "channelId":"${channelId}", 
                              "position":${position}, 
                              "videoId":"${videoId}", 
                              "publishedAt":"${publishedAt}", 
                              "playlistId":"${playlistId}", 
                              "thumbnail":"${thumbnailv}"                              
                             }`;                            

                          let json_video = JSON.parse( j );   
                          _json[playlistId].videos.push(json_video);                            

                          if ( countVideos === videosLength ) {                                                               
                              
                              if ( countPlaylist === playlistLength ) {                                  

                                //response.status(200).send(_json);                        

                                resolve(_json);

                              }
                              
                              countPlaylist++; 
                              countVideos = 1;

                          }  else  {

                            json += `,`;

                          }                     
                          
                          countVideos++;

                        });

                        return {};              

                    }).catch((error) => {     
                      console.error("Error adding document: ", error);           
                    }); 

                  });

                  return {};  

              }).catch((error) => {     
                console.error("Error adding document: ", error);           
              });

          }); 

          return result;

        } catch (e) {
          console.error(e);
          response.status(500).send({ error: e });
          return e;
        } 

  }); 

  
  exports.control = functions.firestore
    .document('control/streaming')
    .onUpdate( async (change, context) => {    

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
              var playlistids = [];
      
              rp(options)              
              .then(async function (results_playlist) {   

                  var restul = JSON.parse(results_playlist);         

                  let lenght = restul.items.length;        

                  var promise_playlist = [];                                  

                  for (var i=0; i<lenght; i++) {                      

                      var json = restul.items[i];   

                      var id = json["id"];  

                      playlistids.push(id);                 

                      promise_playlist.push(
                        firestore.collection("media").doc(id).set(json,{merge:true})
                      );                  
                     
                  }  

                  return await Promise.all(promise_playlist);  
                  

              })
              .then(async (resutls) => {                         

                let playlistidsLength = playlistids.length;

                console.log(" --- playlistidsLength --- " + playlistidsLength);

                var ps = [];

                for (var i=0; i<playlistidsLength; i++) {             

                  var id  = playlistids[i];               

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

                  var promise_videos = [];            

                  var json_videos = JSON.parse("[" + results_promise_videos + "]");                              

                  for (var i in json_videos) {

                      console.log("i: " + i);

                      let result = json_videos[i];                 

                      var items = result.items;

                      var length_playlists = items.length;
                      var count = 0;

                      console.log(
                          " ------ length_playlists ------- " + length_playlists
                      );                                    

                      if (length_playlists>0) {                                    

                        for (var j=0; j<length_playlists; j++) {                     

                            var item = items[j];

                            console.log("item: " + JSON.stringify(item));

                            var id          = item.id;                      
                            var etag        = item.etag;

                            var snippet     = item.snippet;  
                            var playlistId  = snippet.playlistId; 

                            promise_videos.push(
                              firestore.collection("media").doc(playlistId).collection("videos").add(item)
                            );  

                        }

                      }
                  }

                  return await Promise.all(promise_videos);

              })
              .then(async (finalresults) => {

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