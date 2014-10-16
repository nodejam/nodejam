To know what Fora is about, see this https://slides.com/jeswin/fora/fullscreen#

This is __not ready__ to be forked yet. Our first priority is to get the foundation right.
The following dates are tentative and might change.

Some re-usable components of fora have been moved to separate packages.
- Fora Build (Build system, stable) https://github.com/jeswin/fora-build
- Fora Models (Object Data Mapper, stable) https://github.com/jeswin/fora-models
- Fora Extensions (Plugin Loading (Fora specific), stable) https://github.com/jeswin/fora-extensions

Development Plan
================

- Make everything isomorphic - Oct 18
- Post Editor Jeswin Kumar · Oct 21
- Create Forum Jeswin Kumar · Oct 22
- Forum Settings Jeswin Kumar · Oct 23
- Permissions Jeswin Kumar · Oct 24
- Forum Members Jeswin Kumar · Oct 25
- Twitter Posting anup kesavan · Oct 27
- Facebook Posting anup kesavan · Oct 29
- User Landing Jeswin Kumar · Oct 30
- User Followers Jeswin Kumar · Nov 01
- User Following Jeswin Kumar · Nov 01
- Add support for Persona.org login anup kesavan - Oct 28
- RSS anup kesavan · Oct 28
- ReactJS Safe Scripts Jeswin Kumar · Oct 28
- 0.1 Alpha, Nov 7

Installation
============
Installation is straight forward on Linux and Mac.
Windows is not supported yet.

### 1. Install dependencies
- Install nodejs, v0.11.9 or greater
- Install mongodb (Use OS package manager: eg: sudo apt-get install mongodb)
- Install graphicsmagick (Use OS package manager: eg: sudo apt-get install graphicsmagick)
- Edit and rename src/conf/settings.config.sample to src/conf/settings.config

### 2. NODE_ENV
In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production

### 3. Install these tools via npm
These are to be installed globally.
```
sudo npm install -g regenerator
sudo npm install -g browserify
sudo npm install -g less
```

### 4. Install npm dependencies
These are dependencies for the fora server.
```
cd server
npm install
cd ..
```

### 5. Build once
Build the app once now.
```
node --harmony build.js --no-monitor --server
```

### 6. Initialize the directories (one time )
```
cd server
./runscript.sh --harmony app/scripts/init/create.js
cd ..
```

### 7. (Optional): Want some test data?
```
cd server
./runscript.sh --harmony app/scripts/setup/setup.js options

options:
    --create            Creates the database
    --delete            Deletes the database (Only available in NODE_ENV=development)
    --recreate          Calls --delete and --create

    --host hostname     Optional. If --host is not specified, localhost is used.
    --post port         Optional. If --port is not specified, 10981 is used.
```

### 8. Edit Settings
Edit server/src/config/settings.json


### 9. RUN!
The build script (build.js) has many options.
```
node --harmony build.js
node --harmony build.js --help
```

### Dev Tips
Skip ES6 transformation for faster build times and easier debugging for client scripts.
But in chrome, you'll have to enable this flag: chrome://flags/#enable-javascript-harmony
```
node --harmony build.js --use-es6
```

Enjoy Fora at localhost:10981
