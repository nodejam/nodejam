Some re-usable components of fora have been moved to separate packages.
- Crankshaft (Build system) https://github.com/jeswin/crankshaft
- Ceramic (Serialization and validation for datatypes based on JSON Schema) https://github.com/jeswin/ceramic
- Ceramic Db (Database backend for Ceramic) https://github.com/jeswin/ceramic-db
- Ceramic MongoDb Backend (Ceramic's Mongo Backend) https://github.com/jeswin/ceramic-backend-mongodb
- Fora Extensions (Extensions and Plugin Management) https://github.com/jeswin/fora-extensions
- Fora Router (Router for Koa) https://github.com/jeswin/fora-router
- Fora Request (Wrapper around Koa Request) https://github.com/jeswin/fora-request
- Fora Request Parser (Parse and HTTP Request into an object) https://github.com/jeswin/fora-request-parser

To know what Fora is about, see this https://slides.com/jeswin/fora/fullscreen#
This is __not ready__ to be forked yet. Our first priority is to get the foundation right.

Installation
============
Installation is straight forward on Linux and Mac.
Windows is not supported yet, but will be supported in future.

### 1. Install dependencies
- Install nodejs, v0.11.9 or greater.
- Install mongodb (Use OS package manager: eg: sudo apt-get install mongodb)
- Install graphicsmagick (Use OS package manager: eg: sudo apt-get install graphicsmagick)

### 2. NODE_ENV
In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=development

### 4. Install npm dependencies
From the main directory
```
npm install

```

### 5. Build once
Build the app once now.
```
node --harmony build.js --no-monitor --server
```

### 6. Initialize the directories (one time)
```
server/runscript.sh --harmony app/scripts/init/create.js
```

### 7. (Optional): Want some test data?
```
server/runscript.sh --harmony app/scripts/setup/setup.js --recreate

Full options:
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

Enjoy Fora by pointing the browser at http://localhost:10981
