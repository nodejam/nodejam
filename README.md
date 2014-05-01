fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/

Fora is not in a usable state right now.
Below are expected completion dates.

Development Plan
================
- ReactJS Safe Scripts Jeswin Kumar · Sat, May 3
- Post Editor Jeswin Kumar · Mon, May 5
- Create Forum Jeswin Kumar · Tue, May 6
- Forum Settings Jeswin Kumar · Tue, May 6
- Permissions Jeswin Kumar · Wed, May 7
- Forum Members Jeswin Kumar · Thu, May 8
- User Landing Jeswin Kumar · Fri, May 9
- User Followers Jeswin Kumar · Fri, May 9
- User Following Jeswin Kumar · Fri, May 9
- Twitter Posting anup kesavan · Sat, May 10
- Facebook Posting anup kesavan · Sat, May 10
- RSS anup kesavan · Sun, May 11
- Improve Install Experience on Mac and Linux anup kesavan 
- Add support for Persona.org login anup kesavan 
- 0.1 Alpha, Thu May 15

Installation
============
The installer script works only on Ubuntu right now. Other distros and Mac is coming soon.

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
- install a modified version of coffeescript to support the yield keyword, from https://github.com/alubbe/coffee-script.git
- install mongodb (via OS package manager)
- install graphicsmagick (via OS package manager)
- edit and rename src/conf/fora.config.sample to src/conf/fora.config
- edit and rename src/conf/settings.config.sample to src/conf/settings.config
- install these modules with npm

```
npm install -g less
npm install -g regenerator
npm install -g react-tools

cd server
npm install koa
npm install koa-route
npm install koa-favicon
npm install koa-hbs    
npm install co
npm install co-body
npm install co-multipart
npm install thunkify    
npm install mongodb
npm install validator
npm install sanitizer
npm install handlebars
npm install fs-extra
npm install gm
npm install oauth
npm install marked
npm install optimist
npm install multiparty
npm install react
npm install path-to-regexp
npm install node-minify
npm install requirejs    
cd ..

cd www-client
npm install node-minify
cd ..    
```

Step 2: Configuration
---------------------
Run this once to setup directories and indexes

```
cd server
./compile.sh
node --harmony app/scripts/init/create.js
```  
In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production
For production, run source node_path.sh to setup NODE_PATH. (./run.sh does this automatically)


Step 3: Running Fora
--------------------
To debug
```
cd server
./debug.sh [--es5]
```
- Attach reload=1 to url params for the page to refresh automatically when you make changes 
- The --es5 option will transform ES6 code to ES5, allowing you to run on stable node. 
- The --no-compile will skip compilation.

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
Before using this, run source node_path.sh to setup NODE_PATH
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

