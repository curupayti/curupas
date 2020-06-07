# Curupas

Mobile project with Flutter and Firebase, this guide was created for Ubuntu Linux but can be useful for Windows and Mac.

# Setup Firebase CLI reference and install local environment

https://firebase.google.com/docs/cli

Install Node

https://nodejs.org/

Install Cli for Windows stand alone or run npm command

```sh
npm install -g firebase-tools
```

# Login

In order to link a local account with a firebase account, you must initialize firebase while an active project is on the web, choose it. 

```sh
firebase login
```

## Functions (firebase backend endpoints)

To initialize the functions it is necessary to clone the branch 'functions' and install the firebase command line following [this guide] (https://firebase.google.com/docs/functions/local-emulator) and run the command.

```
git clone git@gitlab.com:JoseVigil/curupa.git
```

To checkout the **functions** branch when not found

```sh
git clone git@gitlab.com:JoseVigil/curupa.git
cd curupa
git remote update
git fetch 
git checkout --track origin/<BRANCH-NAME> -use functions branch
```

Init commands

```sh
firebase init
```

Mark all options, OVERRIDE RULES! Allways bring them from the server.

```sh
ENTER, N, ENTER, N, ENTER, N, Javascript, ENTER, N, N, N, ENTER, public, ENTER, N, N, ENTER
```

To run Visual Studio Code with root access command

```sh
sudo code --user-data-dir="~/.vscode-root"
```

Start emulators

```sh
sudo firebase emulators:start

```
If the port is busy, start with

```sh
sudo firebase serve
```

Deploy (only Jose)

```sh
sudo firebase deploy
```

Local port test 

curl -X POST -H "Content-Type: application/json"  -d '{"data":{"name":"YOUR_NAME"}}'  http://localhost:5000/curupa-d830b/us-central1/helloWorld


## Flutter start project form scratch

Create a new flutter project

```sh
flutter create --androidx --org com.curupayti curupas
```

Notice the final package name is com.curupayti.curupas. If the project already existed migrate lib folder by creating the folders manually and moving the files also manually. 

## Firebase 

Creado en base a la cuenta curupasapp@gmail.com

# Create new project

Create new project.

Enable database and storage, allow permission on both rules for testing. Read write true.

# Initialize SDK

In order to use firestore on functions you need to initilize the app with "Firebase Admin SDK" certificate 

Settings -> Service Account -> Firebase Admin SDK -> Node.js

Keep generated json

# Enable Authentication

Go to Authentication -> Signe-in methods -> Enable email and facebook

# Facebook login

Facebook Developers https://developers.facebook.com/apps/911713599192029 Curupas App

AppId: 911713599192029 
App Secret: 9d176aecb3e71f48479a16990faddb94

URI: https://curupas-app.firebaseapp.com/__/auth/handler

Product -> Facebook Login -> Valid OAuth Redirect URIs -> Pegar URI

**Add Application iOS and Android**

Package name: com.curupayti.curupas


