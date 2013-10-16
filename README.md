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

  --node              Install a pre-compiler version of node
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
    npm install -g less     
    cd server
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
    npm install forever  
    npm install marked  
    npm install optimist  
    npm install forever 
    npm install q

Step 2: Configuration
---------------------
- In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production

Step 3: Running Fora
--------------------
To debug
```
cd server
./run.sh --debug
```

For production
```
cd server
./run.sh
```

Step 4: Run once
----------------
This initializes the application's databases, data directories etc.  
Run this every year, afterwards. :)
```
./runonce.sh
```

Step 5 (Optional): Want some test data?
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

