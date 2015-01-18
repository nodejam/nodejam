#This checks if there are uncommitted files in any of the projects associated with fora

check_status_of_repos() {
    curdir=`pwd`
    proj=$1
    basedir=$2
    echo checking $basedir/$proj
    cd $basedir/$proj
    git status
    cd $curdir
    echo
}

check_status_of_repos "nodefunc-generatorify" "node_modules"
check_status_of_repos "crankshaft" "node_modules"
check_status_of_repos "crankshaft-tools" "node_modules"
check_status_of_repos "ceramic" "node_modules"
check_status_of_repos "ceramic-db" "node_modules"
check_status_of_repos "ceramic-backend-mongodb" "node_modules"
check_status_of_repos "ceramic-dictionary-parser" "node_modules"
