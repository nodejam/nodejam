#This checks if there are uncommitted files in any of the projects associated with fora

npm_publish() {
    curdir=`pwd`
    proj=$1
    basedir=$2
    echo checking $basedir/$proj
    cd $basedir/$proj
    npm publish
    cd $curdir
    echo
}

npm_publish "nodefunc-generatorify" "node_modules"
npm_publish "crankshaft" "node_modules"
npm_publish "crankshaft-tools" "node_modules"
npm_publish "ceramic" "node_modules"
npm_publish "ceramic-db" "node_modules"
npm_publish "ceramic-backend-mongodb" "node_modules"
npm_publish "ceramic-dictionary-parser" "node_modules"
