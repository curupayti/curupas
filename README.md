# Curupas

Proyecto mobile camadas con Flutter y Firebase

## Flutter

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

# Setup Firebase CLI reference

https://firebase.google.com/docs/cli

Install Node

https://nodejs.org/

Install Cli for Windows stand alone or run npm command

https://firebase.tools/bin/win/instant/latest

```sh
npm install -g firebase-tools
```

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

# Login

Para poder vincular una cuenta local con una de firebase hay que inicializar firebase estando en la web un proyecto activo elegirlo. 

```sh
firebase login
```

Ir a la consola y habilitar Hosting y Functions.

Si el backend ya estaba funcionando en otro proyecto hay que agregarlo al actual.

```sh
firebase use --add
```

Cuando pide un aliar usar

```sh
default
```

## Functions

Para inicializar las funciones es necesario clonar el branch 'functions' e instalar la linea de comandos firebase siguiendo [esta guia](https://firebase.google.com/docs/functions/local-emulator) y correr el comando

```
git clone git@gitlab.com:JoseVigil/curupa.git
```

To checkout branch when not found

```sh
git clone git@gitlab.com:JoseVigil/curupa.git
cd curupa
git remote update
git fetch 
git checkout --track origin/<BRANCH-NAME>
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
Si el puerto esta ocupado errancar con

```sh
sudo firebase serve
```

Deploy

```sh
sudo firebase deploy
```

curl -X POST -H "Content-Type: application/json"  -d '{"data":{"name":"YOUR_NAME"}}'  http://localhost:5000/curupa-d830b/us-central1/helloWorld





