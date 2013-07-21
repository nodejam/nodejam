fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/

Install instructions (Ubuntu 13.04)
===================================
Note: This should also work on earlier versions of Ubuntu.

sudo apt-get install build-essential  
    - To build node.js from source.  
    - node.js packaged with the distro is often outdated.  
    
sudo apt-get build-dep nodejs  
    
Install node.js  
    - Download source tarball from nodejs.org  
    - configure  
    - make  
    - sudo make install  

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

Edit the config
---------------
Copy server/src/conf/index.coffee.sample to server/src/conf/index.coffee
Edit it if necessary. Not required for development setup.


/etc/hosts
----------
For development set local.foraproject.org to localhost  
You could use any other, but that's the path expected by the setup script.  


Setup
-----
The setup scripts put some data in the database. So that we can play with the app.  
It also helps in testing if the app is working fine. For the scripts to work, the web app must be running with the above config.  

cd to fora/server  
\#create the database  
node app/scripts/setup/setup.js --create  
\#delete the database  
node app/scripts/setup/setup.js --delete  
\#recreate the database  
node app/scripts/setup/setup.js --recreate  


Mongodb Security
----------------
Edit /etc/mongodb.conf  
bind_ip = 127.0.0.1  
port = MONGODB_PORT  


NODE_ENV
--------
To run the setup script, this must be set to 'development'.
This is done so that you don't accidentally destroy the production database.


NODE_PATH
---------
Because the path the node modules was changed, make this change in .bashrc  
export NODE_PATH="/usr/local/lib/node_modules"

Otherwise, you could run this as root:  
rm /usr/local/lib/node  
ln -s /usr/local/lib/node_modules /usr/local/lib/node  

