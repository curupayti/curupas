	
	//calendar
		//camada
		//curupa
		//partidos
	//group
		//anecdotas
		//giras
		//media
	//home
		//description
		//museums
		//newsletter
		//posts
		//pumas
		//valores
	//main
		//user
		//drawer
	//profile
		//notification


	/* 	calendar */

	exports.calendarCamadaUpdate = functions.firestore
	      .document('calendar/camada/camada_collection/{calendarCamadaId}')
	      .onWrite( async (change,contex) => {

		await firestore
		.collection("updates")
		.doc("calendar")
		.set({camada:new Date()}, { merge: true });

		/*const documentId = contex.params.calendarCamadaId;
		await firestore
		.collection("calendar")
		.doc("camada")
		.collection("camada_collection")
		.doc(documentId)
		.set({camada:new Date()}, { merge: true });*/		

	});

	exports.calendarCurupaUpdate = functions.firestore
	      .document('calendar/curupa/curupa_collection/{calendarCurupaId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("calendar")
		.set({curupa:new Date()}, { merge: true });

		/*const documentId = contex.params.calendarCurupaId;
		await firestore
		.collection("calendar")
		.doc("curupa")
		.collection("curupa_collection")
		.doc(documentId)
		.set({curupa:new Date()}, { merge: true });*/

	});

	exports.calendarPartidosUpdate = functions.firestore
	      .document('calendar/partidos/partidos_collection/{calendarPartidosId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("calendar")
		.set({partidos:new Date()}, { merge: true });

		/*const documentId = contex.params.calendarPartidosId;
		await firestore
		.collection("calendar")
		.doc("partidos")
		.collection("partidos_collection")
		.doc(documentId)
		.set({curupa:new Date()}, { merge: true });*/

	});

	/* group */

	exports.anecdotesUpdate = functions.firestore
	      .document('contents/anecdote/collection/{anecdotesId}')
	      .onWrite( async (change,contex) => {	   

		await firestore
		.collection("updates")
		.doc("group")
		.set({anecdote:new Date()}, { merge: true });

		/*const documentId = contex.params.anecdotesId;
		await firestore
		.collection("contents")
		.doc("anecdote")
		.collection("collection")
		.doc(documentId)
		.set({anecdote:new Date()}, { merge: true });*/

	});

	exports.girasUpdate = functions.firestore
	      .document('contents/giras/collection/{girasId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("group")
		.set({giras:new Date()}, { merge: true });

		/*const documentId = contex.params.girasId;
		await firestore
		.collection("contents")
		.doc("giras")
		.collection("collection")
		.doc(documentId)
		.set({giras:new Date()}, { merge: true });*/

	});

	exports.mediaUpdate = functions.firestore
	      .document('years/{yearsId}/media/{mediaId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("group")
		.set({media:new Date()}, { merge: true });

		/*const yearsId = contex.params.yearsId;
		const mediaId = contex.params.mediaId;
		await firestore
		.collection("years")
		.doc(yearsId)
		.collection("media")
		.doc(mediaId)
		.set({media:new Date()}, { merge: true });*/

	});

	/* home */

	exports.descriptionUpdate = functions.firestore
	      .document('titles/home')
	      .onWrite( async (change,contex) => {	

		await firestore
		.collection("updates")
		.doc("home")
		.set({description:new Date()}, { merge: true });

		/*await firestore
		.collection("titles")		
		.doc("home")
		.set({description:new Date()}, { merge: true });*/

	});

	exports.museumsUpdate = functions.firestore
	      .document('museums/{museumId}')
	      .onWrite( async (change,contex) => {

		await firestore
		.collection("updates")
		.doc("home")
		.set({museums:new Date()}, { merge: true });

		/*const museumId = contex.params.museumId;
		await firestore
		.collection("museums")		
		.doc(museumId)
		.set({museums:new Date()}, { merge: true });*/

	});

	exports.newsletterUpdate = functions.firestore
	      .document('contents/newsletter/collection/{newsletterId}')
	      .onWrite( async (change,contex) => {	   

		await firestore
		.collection("updates")
		.doc("home")
		.set({newsletter:new Date()}, { merge: true });

		/*const newsletterId = contex.params.newsletterId;
		await firestore
		.collection("contents")
		.doc("newsletter")
		.collection("collection")
		.doc(newsletterId)
		.set({newsletter:new Date()}, { merge: true });*/

	});

	exports.postsUpdate = functions.firestore	
	      .document('posts/{postId}')
	      .onWrite( async (change,contex) => {	

		await firestore
		.collection("updates")
		.doc("home")
		.set({posts:new Date()}, { merge: true });

		/*const postId = contex.params.postId;
		await firestore
		.collection("posts")		
		.doc(postId)
		.set({posts:new Date()}, { merge: true });*/

	});

	exports.pumasUpdate = functions.firestore	
	      .document('contents/pumas/collection/{pumasId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("home")
		.set({ pumas : new Date()}, { merge: true });

		/*const pumasId = contex.params.pumasId;
		await firestore
		.collection("contents")
		.doc("pumas")
		.collection("collection")
		.doc(pumasId)
		.set({pumas:new Date()}, { merge: true });*/

	});

	exports.valoresUpdate = functions.firestore
	      .document('contents/valores/collection/{valoresId}')
	      .onWrite( async (change,contex) => {	

		await firestore
		.collection("updates")
		.doc("home")
		.set({ valores : new Date()}, { merge: true });

		/*const valoresId = contex.params.valoresId;
		await firestore
		.collection("contents")
		.doc("valores")
		.collection("collection")
		.doc(valoresId)
		.set({valores:new Date()}, { merge: true });*/

	});

	/* main */

	exports.userUpdate = functions.firestore
	      .document('users/{userId}')
	      .onWrite( async (change,contex) => {	

		await firestore
		.collection("updates")
		.doc("main")
		.set({ user : new Date()}, { merge: true });

		/*const userId = contex.params.userId;
		await firestore
		.collection("users")		
		.doc(userId)
		.set({posts:new Date()}, { merge: true });*/

	});

	exports.drawerUpdate = functions.firestore
	      .document('contents/drawer/collection/{drawerId}')
	      .onWrite( async (change,contex) => {	  

		await firestore
		.collection("updates")
		.doc("main")
		.set({ drawer : new Date()}, { merge: true });

	});

	/* profile */

	exports.notificationUpdate = functions.firestore
	      .document('notifications/{notificationId}')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("profile")
		.set({ notification : new Date()}, { merge: true });

	});

	exports.notificationUserTokenUpdate = functions.firestore
	      .document('notifications/{notificationId}/user-token-chat/{userTokenChatId }')
	      .onWrite( async (change,contex) => {	 

		await firestore
		.collection("updates")
		.doc("profile")
		.set({ notification : new Date()}, { merge: true });

	});



	




	


