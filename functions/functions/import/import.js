	
	const firestoreService = require('firestore-export-import');
	const serviceAccount = require('../key/curupas-app-firebase-adminsdk-5t7xp-cb5f62c82a.json');
	const fs = require('fs');	

	const args = process.argv.slice(2);
	if (args[0].includes('emulate')) {
	    process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';    
	}

	firestoreService.initializeApp(
		serviceAccount, 
		`https://${serviceAccount.project_id}.firebaseio.com`
	);

	var file = args[1];

	let json_file = "./files/" + file;

	let params = {
	  dates: ['last_update', 'time_created'],
	  //geos: ['location', 'locations'],
	  refs: ['group_ref'],
	  nested: true,
	};

	//TODO: Fix formats, ask https://github.com/dalenguyen 
	//firestoreService.restore(json_file, params);
	//firestoreService.restore(json_file);

	try {
		if (fs.existsSync(json_file)) {
			firestoreService.restore(json_file, params);
		}
	  } catch(err) {
		console.error(err)
	  }