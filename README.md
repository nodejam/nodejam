fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/

IMPORTANT
---------
We have decided to use es6 generators available via node --harmony
- The yield keyword *significantly* improves readability and maintainability
  So much so that the risk is worth taking.
- You will have to get node 0.11+ for this work
- This requires support in coffee-script for the yield keyword  
  Support has not landed yet. So pull our modified CS compiler from https://github.com/jeswin/coffee-script  

Steps to build CS
-----------------
You will need coffee-script installed to compile the latest version so
```
sudo npm install -g coffee-script  
```
then

```
git clone https://github.com/jeswin/coffee-script  
sudo npm install -g mkdirp  
npm install jison  
cake build:parser  
cake build  
sudo cake install  
```

Install instructions (Ubuntu 13.04)
===================================
Note: This should also work on earlier versions of Ubuntu.

Build node from source, since the bundled node is often outdated.
Download source tarball from nodejs.org

```
sudo apt-get install build-essential  
sudo apt-get build-dep nodejs  
cd to/node/source-code/directory/
configure
make
sudo make install
```

Install everything else    
```
sudo apt-get install nginx  
sudo apt-get install git  
sudo apt-get install mongodb  
sudo apt-get install graphicsmagick  
sudo npm install -g coffee-script  
npm install express  
npm install mongodb  
npm install validator  
npm install sanitizer  
npm install hbs  
npm install fs-extra  
npm install gm  
npm install mongo-express  
npm install node-minify  
npm install oauth  
npm install forever  
npm install marked  
npm install less  
npm install optimist
```

nginx configuration file
------------------------

```
server {
    listen 80;
    server_name local.foraproject.org;
    client_max_body_size 20M;

    location /pub {
        alias /home/jeswin/Desktop/repos/fora/server/www-user;
    }

    location /css {
        alias /home/jeswin/Desktop/repos/fora/server/app/www/css;
    }

    location /images {
        alias /home/jeswin/Desktop/repos/fora/server/app/www/images;
    }

    location /js {
        alias /home/jeswin/Desktop/repos/fora/server/app/www/js;
    }

    location /lib {
        alias /home/jeswin/Desktop/repos/fora/server/app/www/lib;
    }

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
    }
}
                       
```      

/etc/hosts
----------
For development set local.foraproject.org to localhost  
You could use any other, but that's the path expected by the setup script.  


Configuration
-------------
Copy src/conf/settings.conf.sample to src/conf/settings.conf  
Copy (or rename) src/conf/fora.conf.sample to src/conf/fora.conf  
Edit these values.


Setup
-----
The setup scripts put some data in the database. So that we can play with the app.  
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

Mongodb Security
----------------
Edit /etc/mongodb.conf  
```
bind_ip = 127.0.0.1  
port = MONGODB_PORT  
```

ENVIRONMENT VARIABLES (export in .bashrc)
-----------------------------------------
```
export NODE_ENV=development #Use 'production' otherwise.
export NODE_PATH=\"/usr/local/lib/node_modules\" #Because the path the node modules was changed, make this change in .bashrc  
```

Instead of setting NODE_PATH, you could also do:
```
rm /usr/local/lib/node  
ln -s /usr/local/lib/node_modules /usr/local/lib/node  
```
