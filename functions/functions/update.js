
	exports.users = functions.firestore
	      .document('users/{userId}')
	      .onWrite( async (change,contex) => {
	      	

	}); 

