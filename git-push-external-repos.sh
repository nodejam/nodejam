#This checks if there are uncommitted files in any of the projects associated with fora

git_push() {
    curdir=`pwd`
    proj=$1
    basedir=$2
    echo checking $basedir/$proj
    cd $basedir/$proj
    git push origin master
    cd $curdir
    echo
}

git_push "crankshaft" "node_modules"
git_push "crankshaft-tools" "node_modules"
git_push "fora-data-utils" "node_modules"
git_push "ceramic" "node_modules"
git_push "ceramic-db" "node_modules"
git_push "ceramic-backend-mongodb" "node_modules"
git_push "fora-extensions-service" "node_modules"
git_push "fora-request" "node_modules"
git_push "fora-request-parser" "node_modules"
git_push "fora-router" "node_modules"
git_push "nodefunc-generatorify" "node_modules"
