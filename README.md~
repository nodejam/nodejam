fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/

Install instructions from new Ubuntu 13.04
===============================================
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
- nginx configuration

```
#This redirects non-www to www urls
server {
    server_name example.com;
    rewrite ^(.*) http://www.example.com$1 permanent;
}

server {
    listen 80;
    server_name www.example.com;
    client_max_body_size 20M;

    location /pub {
        alias /path/to/fora/server/www-user;
    }

    location /css {
        alias /path/to/fora/server/app/www/css;
    }

    location /html {
        alias /path/to/fora/server/app/www/html;
    }

    location /images {
        alias /path/to/fora/server/app/www/images;
    }

    location /js {
        alias /path/to/fora/server/app/www/js;
    }

    location /lib {
        alias /path/to/fora/server/app/www/lib;
    }

    location /templates {
        alias /path/to/fora/server/app/www/templates;
    }

    location / {
        proxy_pass http://localhost:9000;
        #root /path/to/fora/server/app/www;
        #try_files $uri /index.html;
        #index index.html;
    }
}                         
```            

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

Because the path the node modules was changed, this is also required to be run (as root):
rm /usr/local/lib/node
ln -s /usr/local/lib/node_modules /usr/local/lib/node 
Or: in .bashrc
export NODE_PATH="/usr/local/lib/node_modules"


Mongodb Security: 
Edit /etc/mongodb.conf
bind_ip = 127.0.0.1
port = MONGODB_PORT
