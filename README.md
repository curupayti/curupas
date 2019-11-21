# Curupas

Proyecto mobile camadas con Flutter y Firebase

## Firebase 

Creado en base a la cuenta curupasdev@gmail.com

# Create new project

Create new project.

Enable database and storage, allow permission on both rules. Read write true.

# Initialize SDK

In order to use firestore on functions you need to initilize the app with "Firebase Admin SDK" certificate 

Settings -> Service Account -> Firebase Admin SDK -> Node.js

Keep generated json

# Enable Authentication

Go to Authentication -> Signe-in methods -> Enable email and facebook

# Login

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

Deploy

```sh
sudo firebase deploy
```

curl -X POST -H "Content-Type: application/json"  -d '{"data":{"name":"YOUR_NAME"}}'  http://localhost:5000/curupa-d830b/us-central1/helloWorld





