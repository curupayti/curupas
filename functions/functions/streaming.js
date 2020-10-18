
  
  var rp = require("request-promise");
  var path = require('path');
  var fs = require('fs'); 

  //const functions = require('firebase-functions');
  var readline = require('readline');
  var {google} = require('googleapis');
  var OAuth2 = google.auth.OAuth2;    
  
  exports.streamingFeed = functions.firestore
    .document('streaming/control')
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

                firestore.collection('streaming').doc("control").set({ 
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
              var APIURL = "https://www.googleapis.com/youtube/v3/playlists?channelId=UCeLNPJoPAio9rT2GAdXDVmw";

              var options = {
                  method: "GET",
                  url: APIURL,
                  headers: {
                      'Content-Type': 'application/json',
                       'Authorization': 'Bearer ' + accessToken
                  }
              };            
          
              console.log(JSON.stringify(options));

              var playlistDoc = await firestore.collection('streaming').doc("playlist").set({});
          
              rp(options)              
              .then(async function (results_playlist) {   

                  var restul = JSON.parse(results_playlist);            

                  console.log(
                      " ------ restul ------- " + JSON.stringify(restul)
                  );

                  let lenght = restul.items.length;                 

                  console.log("length: " + lenght); 

                  let count = 0;   
                  var promises_playlist = [];                   

                  for (var i=0; i<lenght; i++) {                      

                      let item = restul.items[i];

                      var id = item["id"];
                      var etag = item["etag"];

                      console.log("id: " + id);
                      console.log("etag: " + etag);

                      var _time =  new Date();

                      var json = {                          
                          etag: etag,                      
                          last_update: _time,                          
                      }
                      
                      promises_playlist.push(
                        firestore.collection('streaming').doc('playlist').collection(id).add(json)
                      );

                      if (count == (lenght-1)) {
                        return promises_playlist;
                      }

                      count++;

                  }               
                  

              })
              .then(async (results) => {
                console.log("results: " + JSON.stringify(results));

                var _time =  new Date();

                return firestore.collection('streaming').doc("control").set({                   
                  get_playlists: false,
                  last_update: _time 
                },{ merge: true });

                
              })
              .then(async (finalresults) => {

                console.log("finalresults: " + JSON.stringify(finalresults));
                return finalresults;

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

      firestore.collection('streaming').doc("control").set({ 
        url_authorization: authUrl, 
        fetch_code_trigger: false,                               
        last_update: _time 
      },{ merge: true }).catch((error) => {
        console.log('Error setting collection:', error);
        return error;
      });

    }