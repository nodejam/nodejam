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

git_push "nodefunc-generatorify" "node_modules"
git_push "crankshaft" "node_modules"
git_push "crankshaft-tools" "node_modules"
git_push "ceramic" "node_modules"
git_push "ceramic-db" "node_modules"
git_push "ceramic-backend-mongodb" "node_modules"
git_push "ceramic-dictionary-parser" "node_modules"
