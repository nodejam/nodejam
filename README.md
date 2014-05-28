This is __not ready__ to be forked yet. Our first priority is to get the foundation right.
The following dates are tentative and might change.

Some re-usable components of fora have been moved to separate packages.
- Fora Build (The build system) https://github.com/jeswin/fora-build 
- Fora Models (Object Data Mapper) https://github.com/jeswin/fora-models 
- Fora Extensions (Plugin Loading etc) https://github.com/jeswin/fora-extensions

Development Plan
================

- Make everything isomorphic - May 30
- ReactJS Safe Scripts Jeswin Kumar · May 1
- Post Editor Jeswin Kumar · June 3
- Create Forum Jeswin Kumar · June 5
- Forum Settings Jeswin Kumar · June 7
- Permissions Jeswin Kumar · June 9
- Forum Members Jeswin Kumar · June 10
- User Landing Jeswin Kumar · June 12
- User Followers Jeswin Kumar · June 13
- User Following Jeswin Kumar · June 15
- Twitter Posting anup kesavan · June 8
- Facebook Posting anup kesavan · June 8
- RSS anup kesavan · Sun, June 8
- Improve Install Experience on Mac and Linux anup kesavan 
- Add support for Persona.org login anup kesavan 
- 0.1 Alpha, June 18

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
npm install -g less regenerator react-tools

cd server
npm install koa koa-route koa-favicon koa-hbs co co-body co-multipart \
    thunkify mongodb validator sanitizer handlebars fs-extra gm oauth \
    markdown optimist multiparty react path-to-regexp node-minify requirejs
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
./runscript.sh --harmony app/scripts/init/create.js
```  
In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production


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
cd server
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
cd server
./runscript.sh --harmony app/scripts/setup/setup.js options

options:
    --create            Creates the database
    --delete            Deletes the database (Only available in NODE_ENV=development) 
    --recreate          Calls --delete and --create
    
    --host hostname     Optional. If --host is not specified, local.foraproject.org is used.
    --post port         Optional. If --port is not specified, 80 is used.
```

Open http://local.foraproject.org in your browser, if you haven't changed the host name. 

