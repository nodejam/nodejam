fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/


Installation
============

Step 1: Install pre-requisites
------------------------------
Run ./install-dependencies.sh
WARNING: The install script upgrades node to a very new version.

```
usage: ./install-dependencies.sh options
options:
  --all               Same as --node --coffee --nginx --nginx_conf --host local.foraproject.org --mongodb --gm --node_modules
  --node              Compile and install node
  --coffee            Compile and install coffee-script, with support for the yield keyword
  --nginx             Install nginx
  --host hostname     Adds an entry into /etc/hosts. eg: --host test.myforaproj.com
  --nginx_conf        Copies a sample nginx config file to /etc/nginx/sites-available, and creates a symlink in sites-enabled
  --mongodb           Install MongoDb
  --gm                Install Graphics Magick
  --node_modules      Install Node Modules
  --help              Print the help screen
Examples:
  ./install-dependencies.sh --all
  ./install-dependencies.sh --node --coffee --gm --node_modules
```

Otherwise, install these manually
- nodejs, v0.11.5 or greater
- mongodb
- nginx
- modified version of coffeescript (to support the yield keyword), from https://github.com/jeswin/coffee-script


Step 2: Configuration
---------------------
- Copy src/conf/settings.config.sample to settings.config and edit it.
- Copy src/conf/fora.config.sample to fora.config and edit it.
- In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production


Step 3: Setting hostname
------------------------
If you used the --all or --nginx_conf options, you will find a file named


Running Fora
------------
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

Fora will be running under the hostname you provided in ./configure.sh. Go to http://hostname in browser.

