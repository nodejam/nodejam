#!/bin/bash

# Installs dependencies for Fora
# Tested only in Ubuntu

help() {
echo "usage: ./install-dependencies.sh options
options:
  --all               Same as --node --coffee --nginx --nginx_conf --host local.foraproject.org --mongodb --gm --node_modules
  --node              Compile and install node
  --coffee            Compile and install coffee-script, with support for the yield keyword
  --nginx             Install nginx
  --nginx_conf        Copies a sample nginx config file to /etc/nginx/sites-available, and creates a symlink in sites-enabled
  --host hostname     Adds an entry into /etc/hosts. eg: --host test.myforaproj.com
  --mongodb           Install MongoDb
  --gm                Install Graphics Magick
  --node_modules      Install Node Modules
  --help              Print the help screen
Examples:
  ./install-dependencies.sh --all
  ./install-dependencies.sh --node --coffee --gm --node_modules"
}

if [ $# -eq 0 ]
  then
    help
    exit 0
fi

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

base_dir=$PWD
node=false
coffee=false
nginx=false
nginx_conf=false
mongodb=false
gm=false
node_modules=false
host=false

while :
do
    case $1 in
        -h | --help | -\?)
            help
            exit 0      # This is not an error, User asked help. Don't do "exit 1"
            ;;
        -a | --all)
            node=true
            coffee=true
            nginx=true
            nginx_conf=true
            host=true
            hostname="local.foraproject.org"
            mongodb=true
            gm=true
            node_modules=true
            shift
            ;;
        --node)
            node=true
            shift
            ;;
        --coffee)
            coffee=true
            shift
            ;;
        --nginx)
            nginx=true
            shift
            ;;
        --nginx_conf)
            nginx_conf=true
            shift
            ;;
        --host)
            host=true
            hostname=$2
            shift 2
            ;;
        --mongodb)
            mongodb=true
            shift
            ;;
        --gm)
            gm=true
            shift
            ;;
        --node_modules)
            node_modules=true
            shift
            ;;
        -*)
            echo "WARN: Unknown option (ignored): $1" >&2
            shift
            ;;
        *)  # no more options. Stop while loop        
            break
            ;;
    esac
done

install_node() {
    sudo apt-get install build-essential            
    sudo apt-get build-dep nodejs
    temp=`mktemp -d`
    git clone https://github.com/joyent/node.git $temp
    cd $temp
    ./configure
    make
    sudo make install
    rm -rf $temp
}

install_coffee() {    
    temp_cs=`mktemp -d`
    
    cd $temp_cs
    echo "Copying Coffee-Script dependencies into $temp_cs"
    npm install coffee-script
    export PATH=$PATH:$PWD/node_modules/coffee-script/bin
    temp_new_cs=`mktemp -d`
    git clone https://github.com/jeswin/coffee-script.git $temp_new_cs
    cd $temp_new_cs
    npm install mkdirp  
    npm install jison
    echo "Building Coffee-Script"
    cake build:parser  
    cake build 
    echo "Installing Coffee-Script"
    sudo npm install -g mkdirp  
    sudo $temp_cs/node_modules/coffee-script/bin/cake install
    
    rm -rf $temp_cs
    rm -rf $temp_new_cs
}

#Node version must not be less than 0.11.5
if $node ; then
    if command -v node >/dev/null; then
        node_version=`node -v | grep -o "[0-9].*"`
        vercomp $node_version "0.11.5"
        result=$?
        if [[ $result -le 1 ]] ; then
            echo "Node version $node_version is installed. Update is not needed."
        else
            echo "Node version is $node_version. Will update."
            install_node
        fi
    else
        echo "Node is not installed. Will install."
        install_node
    fi
fi

#coffee-script compiler must support yield
if $coffee ; then
    if command -v coffee >/dev/null; then
        coffee --nodejs --harmony -e "a = (-> yield 1)"
        if [ "$?" -eq 0 ] ; then
            echo "Coffee-Script is installed and supports yield. Update is not needed."
        else
            echo "Coffee-Script is installed but does not support yield. Will update compiler." 
            install_coffee
        fi
    else
        echo "Coffee-Script is not installed. Will install."
        install_coffee
    fi
fi

cd $base_dir

if $nginx ; then
    if command -v nginx >/dev/null; then
        echo "Nginx is already installed."
    else
        echo "Nginx is not installed. Will install."
        sudo apt-get install nginx
    fi
fi

if $nginx_conf ; then
    if [ ! -f /etc/nginx/sites-available/fora.conf ]; then
        cat fora.nginx.conf | sed -e 's_/path/to/fora/_'"$PWD"'/_g' > /etc/nginx/sites-available/fora.conf
        ln -s /etc/nginx/sites-available/fora.conf /etc/nginx/sites-enabled/fora.conf
    else
        echo "/etc/nginx/sites-available/fora.conf exists. Will not overwrite, you must delete it manually."
    fi
fi

if $host ; then
    if grep -Fxq "$hostname" /etc/hosts ; then
        echo "/etc/hosts already contains an entry for $hostname. Will not update."
    else
        echo "Adding to /etc/hosts..."
        echo "#This was added by Fora" | sudo tee -a /etc/hosts
        echo "127.0.0.1 $hostname" | sudo tee -a /etc/hosts
    fi    
fi

if $mongodb ; then
    if command -v mongod >/dev/null; then
        echo "Mongodb is already installed."
    else
        echo "Mongodb is not installed. Will install."
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
        echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
        sudo apt-get update
        sudo apt-get install mongodb-10gen
        sudo mkdir -p /data/db
        sudo chmod 0755 /data/db
        sudo chown mongodb /data/db
    fi
fi

if $gm ; then
    sudo apt-get install graphicsmagick
fi

if $node_modules ; then
    sudo npm install -g less    
    
    cd server
    npm install express
    npm install mongodb
    npm install validator
    npm install sanitizer
    npm install hbs
    npm install fs-extra
    npm install gm
    npm install node-minify
    npm install oauth
    npm install forever
    npm install marked
    npm install optimist
    npm install forever
    cd ..
fi

echo "Install complete."
