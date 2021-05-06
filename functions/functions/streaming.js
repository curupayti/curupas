  var rp = require("request-promise");
  var path = require('path');
  var fs = require('fs'); 

  //const functions = require('firebase-functions');
  var readline = require('readline');
  var {google} = require('googleapis');
  var OAuth2 = google.auth.OAuth2;  

  //googleapis refresh token
  //https://stackoverflow.com/questions/61204084/nodejs-how-to-get-new-token-with-refresh-token-using-google-api

  var DeleteCollection = function (path, callback) {
    firestore.collection(path).listDocuments().then(val => {
        val.map((val) => {
            return val.delete();
        });
        callback();
        return {};
    }).catch((error) => {
      console.log('Error saving videos:', error);
      return error;
    });
  } 

  exports.control = functions.firestore
    .document('streaming/control')
    .onUpdate( async (change, context) => {    

      var newValue = change.after.data();       
      var fetch_code_trigger    = newValue.fetch_code_trigger;     
      var fetch_token_trigger   = newValue.fetch_token_trigger;
      var get_playlists         = newValue.get_playlists;
      var convert_playlists     = newValue.convert_playlists;
      var last_update           = newValue.last_update.toDate();
      var refresh_access_tokens = newValue.refresh_access_tokens;

      var expiry_date;
      if (newValue.tokens) {
              expiry_date = newValue.tokens.expiry_date;    
      }
      var token_expiry_date_stored = newValue.token_expiry_date_stored;

      console.log("fetch_code_trigger: " + fetch_code_trigger);
      console.log("fetch_token_trigger: " + fetch_token_trigger);
      console.log("get_playlists: " + get_playlists);
      console.log("convert_playlists: " + convert_playlists);
      console.log("refresh_access_tokens: " + refresh_access_tokens);
      console.log("last_update: " + last_update);
      console.log("");

      var client_secret = path.join(__dirname, '/key/client_secret.json');
      var code = newValue.code;       

      if ( fetch_token_trigger || get_playlists ) {   

        var oauth2Client;
        
        //fs.readFile(client_secret, async function processClientSecrets(err, content) {
        //fs.readFile(client_secret, (err, content) => {

          var content = fs.readFile(client_secret); 
          
          if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
          }

          let credentials = JSON.parse(content);
        
          let clientSecret = credentials.web.client_secret;
          let clientId = credentials.web.client_id;
          let redirectUrl = credentials.web.redirect_uris[0];
          oauth2Client = new OAuth2(clientId, clientSecret, redirectUrl);        

          console.log("code: " + code);

          if (fetch_token_trigger)  {
          
            try {

                const _tokens = await oauth2Client.getToken(code);             

                var _time =  new Date();

                console.log("::: Updating ::: fetch_token_trigger");

                firestore.collection("streaming").doc("control").set({ 
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
              .then(async (results_playlist) => {   

                  var restul = JSON.parse(results_playlist);         

                  let lenght = restul.items.length;        

                  var promise_playlist = [];                                  

                  for (var i=0; i<lenght; i++) {                      

                      var json = restul.items[i];   

                      var id = json["id"];  

                      playlistids.push(id);                 

                      /*promise_playlist.push(
                        firestore.collection("media").doc(id).set(json,{merge:true})
                      );*/

                      promise_playlist.push(
                        firestore.collection("streaming").doc("control").collection("media").doc(id).set(json,{merge:true})
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

                            /*promise_videos.push(
                              firestore.collection("media").doc(playlistId).collection("videos").add(item)
                            );*/

                            promise_videos.push(
                              firestore.collection("streaming").doc("control").collection("media").doc(playlistId).collection("videos").add(item)
                            );  

                        }

                      }
                  }

                  return await Promise.all(promise_videos);

              })
              .then(async (finalresults) => {

                  console.log("::: Updating ::: get_playlists");

                  var _time =  new Date();

                  return firestore.collection("streaming").doc("control").set({                   
                    get_playlists: false,
                    convert_playlists : true,
                    last_update: _time 
                  },{ merge: true });
                  
                })                
                .catch((err) => {
                    console.log("error: " + err );
                });                        
                 

              }

          //});

      }

      
      if ( fetch_code_trigger ) {        
        
        let TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH ||
            process.env.USERPROFILE) + '/.credentials/';
        TOKEN_PATH = TOKEN_DIR + 'youtube-nodejs-quickstart.json';        
        
        fs.readFile(TOKEN_PATH, (err, content) => {
        
          if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
          }          
          authorize(JSON.parse(content));
        });       

      } 

      if ( refresh_access_tokens ) {        
        
        let TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH ||
            process.env.USERPROFILE) + '/.credentials/';
        TOKEN_PATH = TOKEN_DIR + 'youtube-nodejs-quickstart.json';        
        //fs.readFile(client_secret, function processClientSecrets(err, content) {
        fs.readFile(client_secret, (err, content) => {
          if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
          }          
          let tokens = newValue.tokens;
          let refreshToken = tokens.refresh_token;
          refreshAccessTokens(JSON.parse(content), refreshToken);
        });       

      } 

      if ( convert_playlists ) {  

          DeleteCollection("streaming/control/videos", () => {

              const result = new Promise(async (resolve, reject) => {

              var promise_playlist = [];
              var playlists = [];

              var promise_videos   = []; 

              var countPlaylist = 1; 

              var playlistLength = 0;

              firestore.collection("streaming").doc("control").collection("media").get()
                .then(async (querySnapshotPlaylist) => {

                  playlistLength = querySnapshotPlaylist.size;                              

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

                      //let j = `{"id":"${idp}","title":"${title}","description":"${description}","channelTitle":"${channelTitle}","channelId":"${channelId}","thumbnail":"${thumbnailp}","publishedAt":"${publishedAt}","videos":[]}`;                    

                      let j = `{                                                
                          "id":"${title}", 
                          "title":"${title}",
                          "uid":"${idp}", 
                          "description":"${description}", 
                          "channelTitle":"${channelTitle}", 
                          "channelId":"${channelId}", 
                          "thumbnail":"${thumbnailp}", 
                          "publishedAt":"${publishedAt}",
                          "videos":[]                      
                      }`; 

                      var json = JSON.parse(j);

                      playlists.push(json);

                      promise_playlist.push(
                        firestore.collection("streaming").doc("control").collection("videos").doc(idp).set(json,{merge:true})
                      );  

                      countPlaylist++; 

                      if ( countPlaylist === playlistLength ) {                                            

                        countPlaylist = 0;
                        return await Promise.all(promise_playlist);

                      } else {
                        return {};  
                      }

                  }); 

                  return {};                

              }).then(async (playlist_results) => {

                  //console.log("playlist_results::::  " + JSON.stringify(playlist_results));

                  var playlist_prmise = [];

                  for (var i=0; i<playlists.length; i++) {

                    var idp = playlists[i].uid;

                    console.log("");
                    console.log("idp: " + idp);                      

                    playlist_prmise.push(firestore.collection("streaming").doc("control").collection("media")
                    .doc(idp).collection("videos"));

                  }

                  return Promise.all(playlist_prmise);

              }).then(async (querySnapshotVideo) => {     

                var promise_videos_resolve = await new Promise( async (resolve, reject) => {           

                    var videosLength = querySnapshotVideo.size;
                    var countVideos = 1;  

                    console.log("videosLength: " + videosLength);                                        

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
                      //let localized     = snippetv.localized;  
                      let channel_title = snippetv.channelTitle;                           
                      let position      = snippetv.position;              

                      let videoId       = snippetv.resourceId.videoId;
                      let publishedAt   = snippetv.publishedAt;                            
                      
                      let playlistId    = snippetv.playlistId;  
                      var thumbnailv    = "";

                      console.log("playlistId:" + playlistId);

                      if (defaulv) {
                        thumbnailv = defaulv.url;
                      }

                      //let j  = `{"id":"${idv}","title":"${title}","description":"${description}","channelId":"${channelId}","position":${position},"videoId":"${videoId}","publishedAt":"${publishedAt}","playlistId":"${playlistId}","thumbnail":"${thumbnailv}"}`;                            

                      let k  = `{                              
                          "id":"${idv}", 
                          "title":"${title}",
                          "uid":"${idv}", 
                          "description":"${description}",                               
                          "channelId":"${channelId}",
                          "channelTitle":"${channel_title}", 
                          "position":${position}, 
                          "videoId":"${videoId}", 
                          "publishedAt":"${publishedAt}", 
                          "playlistId":"${playlistId}", 
                          "thumbnail":"${thumbnailv}"                              
                          }`;  

                      let json_video = JSON.parse( k );    

                      promise_videos.push(
                        firestore.collection("streaming").doc("control").collection("videos").doc(playlistId).collection("videos").add(json_video)
                      );                         

                      console.log("countVideos: " + countVideos + " videosLength: " + videosLength + " countPlaylist: " + countPlaylist + " playlistLength: " + playlistLength);   

                      if ( countVideos === videosLength ) {                                                                                               
                        if ( countPlaylist === playlistLength ) {                         

                          //return Promise.all(promise_videos);                                                        
                          resolve(promise_videos);
                        }                                
                        countPlaylist++; 
                        countVideos = 1;
                      }                                               
                      countVideos++;

                    });

                  });

                  return Promise.all(promise_videos_resolve);  

              }).then(async (promise_videos_results) => {

                  console.log("::: Updating ::: convert_playlists");       

                  var _time =  new Date();

                  firestore.collection("streaming").doc("control").set({                   
                    convert_playlists: false,
                    last_update: _time 
                  },{ merge: true });    

                  resolve(true); 
                  return {};  

              // end 
              }).catch((error) => {
                console.log('Error saving videos:', error);
                return error;
              });

          // end promise
          }); 

        //end of deleting collection
        });         
          
      }     

    }); 

    function authorize(credentials, callback) {
      
      let clientSecret = credentials.web.client_secret;
      let clientId = credentials.web.client_id;
      let redirectUrl = credentials.web.redirect_uris[0];
      var oauth2Client = new OAuth2(clientId, clientSecret, redirectUrl);

      // Check if we have previously stored a token.
      fs.readFile(TOKEN_PATH, (err, token) => {
        if (err) {
          return getNewToken(oauth2Client, callback);
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

      firestore.collection("streaming").doc("control").set({ 
        url_authorization: authUrl, 
        fetch_code_trigger: false,                               
        last_update: _time 
      },{ merge: true }).catch((error) => {
        console.log('Error setting collection:', error);
        return error;
      });

    }

    var refreshAccessTokens = function (credentials, refreshToken) {

      let clientSecret    = credentials.web.client_secret;
      let clientId        = credentials.web.client_id;
      let redirectUrl     = credentials.web.redirect_uris[0];
      var oauth2Client    = new OAuth2(clientId, clientSecret, redirectUrl);

      /*let oauth2Client = new google.auth.OAuth2(
             secret.clientID,
             secret.clientSecret,
             secret.redirectUrls
      );*/

      console.log("clientSecret: " + clientSecret);
      console.log("clientId: " + clientId);
      console.log("redirectUrl: " + redirectUrl);
      console.log("clientSecret: " + clientSecret);
      console.log("oauth2Client: " + JSON.stringify(oauth2Client));
      console.log("");

      oauth2Client.credentials.refresh_token = refreshToken;

      oauth2Client.refreshAccessToken( async (error, tokens) => {

        var _time =  new Date();

        console.log("::: Refresh ::: refresh_access_tokens");

        console.log("tokens : " + JSON.stringify(tokens));

        firestore.collection("streaming").doc("control").set({ 
          tokens: tokens,
          refresh_access_tokens: false,
          last_update: _time 
        },{ merge: true }).catch((error) => {
          console.log('Error setting collection:', error);
          return error;
        });
      
      });

    }