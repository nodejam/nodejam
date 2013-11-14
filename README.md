fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/


Installation
============

Step 1: Install pre-requisites
------------------------------
Run ./install-ubuntu.sh --all (or see options below)
WARNING: The install script upgrades node to a very new version.

```
usage: ./install-ubuntu.sh options
options:
  --all               Same as --node --coffee --nginx --nginx-conf --host local.foraproject.org --mongodb --gm --config-files --node-modules
  --latest            Same as --node-latest --coffee --nginx --nginx-conf --host local.foraproject.org --mongodb-latest --gm --config-files --node-modules

  --node              Install a pre-compiled version of node
  --node-latest       Compile and install the latest node
  --coffee            Compile and install coffee-script, with support for the yield keyword
  --nginx             Install nginx
  --nginx-conf        Copies a sample nginx config file to /etc/nginx/sites-available, and creates a symlink in sites-enabled
  --host hostname     Adds an entry into /etc/hosts. eg: --host test.myforaproj.com
  --mongodb           Install a pre-compiler version of MongoDb
  --mongodb-latest    Compile and install the latest MongoDb  
  --gm                Install Graphics Magick
  --config-files      Creates config files if they don't exist
  --node-modules      Install Node Modules

  --help              Print the help screen

Examples:
  ./install-ubuntu.sh --all
  ./install-ubuntu.sh --node --coffee --gm --node-modules
```

If you aren't running the script, you'll have to do these manually:
- install nodejs, v0.11.5 or greater
- install nginx (via OS package manager)
- setup nginx configuration, see nginx.config.sample
- install a modified version of coffeescript to support the yield keyword, from https://github.com/jeswin/coffee-script
- install mongodb (via OS package manager)
- install graphicsmagick (via OS package manager)
- edit and rename src/conf/fora.config.sample to src/conf/fora.config
- edit and rename src/conf/settings.config.sample to src/conf/settings.config
- install these modules with npm:
```
npm install -g less
npm install -g regenerator
npm install express  
npm install mongodb  
npm install validator  
npm install sanitizer  
npm install handlebars  
npm install hbs  
npm install fs-extra  
npm install gm  
npm install node-minify  
npm install oauth  
npm install marked  
npm install optimist  
npm install q  
npm install multiparty  
```

Step 2: Configuration
---------------------
Run this once to setup directories and indexes
```
node --harmony app/scripts/init/index.js
```  
In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production


Step 3: Running Fora
--------------------
To debug
```
cd server
./debug.sh [--es5]
```
- The --es5 option will transform ES6 code to ES5, allowing you to run on stable node. 

For production
```
./compile.sh [--es5]
```
And run with monitoring tools such as upstart and monit.  
- The services you need to run are app/website/app.js, app/api/app.js
- Check the sample files upstart-fora-app.conf, upstart-fora-api.conf and monit-fora
- The --es5 option will transform ES6 code to ES5, allowing you to run on stable node.

Note:  
ES6 to ES5 transformation is done with Regenerator (https://github.com/facebook/regenerator).


Step 4 (Optional): Want some test data?
-------------------------------------
```
usage: node --harmony app/scripts/setup/setup.js options

options:
    --create            Creates the database
    --delete            Deletes the database (Only available in NODE_ENV=development) 
    --recreate          Calls --delete and --create
    
    --host hostname     Optional. If --host is not specified, local.foraproject.org is used.
    --post port         Optional. If --port is not specified, 80 is used.
```

Open http://local.foraproject.org in your browser, if you haven't changed the host name. 

