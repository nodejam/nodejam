fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/


Installation for Ubuntu 13.04
=============================
If you are using Ubuntu, you just need to run the following scripts (in order):
- ./install-dependencies.sh
- ./configure.sh --host <domain_name>
- ./setup.sh

For advanced usage and other operating systems (BSD/*nix), install these manually.


Step 1: Install pre-requisites
------------------------------
Run ./install-dependencies.sh -all OR install these manually.
- nodejs, v0.11.5 or greater
- mongodb
- nginx
- modified version of coffeescript (to support the yield keyword), from https://github.com/jeswin/coffee-script

WARNING: The install script upgrades node to a very new version.

```
./install-dependencies.sh --node --coffee --host <host_name>
    --node              Compile and install node (optional)
    --coffee            Compile and install coffee-script, with support for the yield keyword (optional)
    --nginx             Install ngnix
    --help              Print the help screen    
Examples:
    ./install-dependencies.sh --all
    ./install-dependencies.sh --node --coffee
```


Step 2: Configuration
---------------------
Run ./configure OR do this manually.
- Edit etc/hosts and add your desired hostname (eg: devsite.foraproject.org)
- Edit src/conf/index.coffee
- Copy src/conf/settings.config.sample to settings.config and edit it.
- Copy src/conf/fora.config.sample to fora.config and edit it.
- If you are planning to use nginx, edit fora.ngnix.conf and copy it to /etc/nginx/sites-available

```
./configure.sh --host <host_name>
    --all               Same as --node --coffee
    --node              Compile and install node (optional)
    --coffee            Compile and install coffee-script, with support for the yield keyword (optional)
    --nginx             Install ngnix
    --help              Print the help screen    
Examples:
    ./install-dependencies.sh --all
    ./install-dependencies.sh --node --coffee
```

Environment Variables (export in .bashrc)
-----------------------------------------
```
export NODE_ENV=development #Use 'production' otherwise.
export NODE_PATH=\"/usr/local/lib/node_modules\" #Because the path the node modules was changed, make this change in .bashrc  
```



Step 3: Setup
-------------
```
./setup.sh --node --coffee --host <host_name> --server <server> --init --recreate_dev_db <db_name>

    --node              Compile and install node
    --coffee            Compile and install coffee-script, with support for the yield keyword
    --host <host_name>  Host name. Will be added to etc/hosts. eg: local.foraproject.org
    --server <server>   nginx OR builtin
    --init              Initializes the app. Should be used the first time
    --recreate_dev_db    Creates a development database
    
Examples:
1) You could use this the first time
    ./setup.sh options --node --coffee --host dev.foraproject.org --server nginx --init --recreate_dev_db fora_dev_db
```


Running Fora
------------
To debug,
```
./run.sh --debug
```

For production

```
./run.sh
```






After the server is running
---------------------------
Run this once.
node --harmony app/scripts/init/index.js









Setup a Test Database
---------------------
The setup scripts put some data in the database, so that we can play with the app.  
It also helps in testing if the app is working fine. For the scripts to work, the web app must be running with the above config.  

cd to fora/server  
```
#create the database  
node --harmony app/scripts/setup/setup.js --create  
#delete the database  
node --harmony app/scripts/setup/setup.js --delete  
#recreate the database  
node --harmony app/scripts/setup/setup.js --recreate  
```
