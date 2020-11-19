    

	var generateShortId = function () {
		var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    	var autoId = '';
		for (let i = 0; i < 5; i++) {
		   autoId += CHARS.charAt(
		     Math.floor(Math.random() * CHARS.length)
		   );
		}
		return autoId;
	}	

   exports.posts = functions.firestore
      .document('posts/{postId}')
      .onCreate( async (snap,contex) => {

  		var data = snap.data();   		
  		const title = data.title;   
  		const documentId = contex.params.postId;  		

      	console.log("id: " + documentId);
      	console.log("title: " + title);		

      	var autoId = generateShortId();

		var _time =  new Date();      	
      	var path = "/posts/" + documentId;
      	var item = {};        
        item.id = autoId; 
        item.document_path = path;
        item.last_update = _time;

        var _share = "https://app.curupas.com.ar/share/" + autoId; 

        await firestore.collection("share").doc(autoId).set(item,{merge:true});		

        firestore.collection("posts").doc(documentId).set({                   
          share: _share,          
          last_update: _time 
        },{ merge: true });

    });   

    exports.museums = functions.firestore
      .document('museums/{museumsId}')
      .onCreate( async (snap,contex) => {

  		var data = snap.data();   		
  		const title = data.title;   
  		const documentId = contex.params.museumsId;  		

      	console.log("id: " + documentId);
      	console.log("title: " + title);		

      	var autoId = generateShortId();

		var _time =  new Date();      	
      	var path = "/museums/" + documentId;
      	var item = {};        
        item.id = autoId; 
        item.document_path = path;
        item.last_update = _time;

        var _share = "https://app.curupas.com.ar/share/" + autoId; 

        await firestore.collection("share").doc(autoId).set(item,{merge:true});		

        firestore.collection("museums").doc(documentId).set({                   
          share: _share,          
          last_update: _time 
        },{ merge: true });

    });


    exports.contents = functions.firestore
      .document('contents/{typeId}/collection/{contentId}')
      .onCreate( async (snap,contex) => {

  		var data = snap.data();   		
  		const title = data.title;   
  		const typeId = contex.params.typeId;
  		const contentId = contex.params.contentId;  		

      	console.log("typeId: " + typeId);
      	console.log("contentId: " + contentId);		

      	if (contentId) {

	      	var autoId = generateShortId();

			var _time =  new Date();      	
	      	var path = "/contents/" + typeId + "/collection/" + contentId;

	      	var item = {};        
	        item.id = autoId; 
	        item.document_path = path;
	        item.last_update = _time;

	        var _share = "https://app.curupas.com.ar/share/" + autoId; 

	        await firestore.collection("share").doc(autoId).set(item,{merge:true});		

	        firestore.collection("contents").doc(typeId)
	        		 .collection("collection").doc(contentId).set({                   
	          share: _share,          
	          last_update: _time 
	        },{ merge: true });

	    }

    });


    exports.calendarevent = functions.firestore
      .document('calendar/{calendarId}/{collectionId}/{eventId}')
      .onCreate( async (snap,contex) => {

  		var data = snap.data();   		
  		const title = data.title;   
  		const calendarId = contex.params.calendarId;
  		const collectionId = contex.params.collectionId;
  		const eventId = contex.params.eventId;  	 		  		

      	console.log("calendarId: " + calendarId);      	
      	console.log("collectionId: " + collectionId);	
      	console.log("eventId: " + eventId);	

      	if (calendarId) {

	      	var autoId = generateShortId();

			var _time =  new Date();      	
	      	var path = "/contents/" + calendarId + "/" + collectionId + "/" + eventId;

	      	var item = {};        
	        item.id = autoId; 
	        item.document_path = path;
	        item.last_update = _time;

	        var _share = "https://app.curupas.com.ar/share/" + autoId; 

	        await firestore.collection("share").doc(autoId).set(item,{merge:true});		

	        firestore.collection("calendar").doc(calendarId)
	        		 .collection(collectionId).doc(eventId).set({                   
	          share: _share,          
	          last_update: _time 
	        },{ merge: true });

	    }

    });

    