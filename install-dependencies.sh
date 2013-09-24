#!/bin/bash

# Installs dependencies
# Tested only in Linux

help() {
echo "./install-dependencies.sh --node --coffee --host <host_name>
  --all               Same as --node --coffee --nginx --mongodb --host local.foraproject.org
  --node              Compile and install node (optional)
  --coffee            Compile and install coffee-script, with support for the yield keyword (optional)
  --nginx             Install ngnix
  --mongodb           Install MongoDb
  --host <host_name>  Host name. Will be added to etc/hosts. (optional)
  --help              Print the help screen
Examples:
  ./install-dependencies.sh --all
  ./install-dependencies.sh --node --coffee --host dev.foraproject.org"
}

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

node=false
coffee=false
nginx=false
mongodb=false
host="local.foraproject.org"

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
            mongodb=true
            host="local.foraproject.org"
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
        --mongodb)
            mongodb=true
            shift
            ;;
        --host)
            host=$2     
            shift 2
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
    rmdir -rf temp/dependencies-node
    git clone https://github.com/joyent/node.git temp/dependencies-node
    cd temp/dependencies-node
    ./configure
    make
    sudo make install
    rmdir -rf temp/dependencies-node
}

install_coffee() {
    rmdir -rf temp/dependencies-coffee
    git clone https://github.com/jeswin/coffee-script.git temp/dependencies-coffee
    cd temp/dependencies-coffee
    npm install mkdirp  
    npm install jison
    cake build:parser  
    cake build 
    sudo cake install
    rmdir -rf temp/dependencies-coffee
}

#Install node if current version is less than 0.11.5
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

    #git clone https://github.com/joyent/node.git temp/node
fi

if $coffee ; then
    if command -v node >/dev/null; then
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

if $nginx ; then
    if command -v node >/dev/null; then
        echo Nginx is already installed.
    else
        echo Nginx is not installed. Will install.
    fi
fi

if $mongodb ; then
    if command -v mongod >/dev/null; then
        echo Mongodb is already installed.
    else
        echo Mongodb is not installed. Will install.
    fi
fi

