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

check_status_of_repos "crankshaft" "node_modules"
check_status_of_repos "crankshaft-tools" "node_modules"
check_status_of_repos "fora-data-utils" "node_modules"
check_status_of_repos "ceramic" "node_modules"
check_status_of_repos "ceramic-db" "node_modules"
check_status_of_repos "ceramic-backend-mongodb" "node_modules"
check_status_of_repos "fora-extensions-service" "node_modules"
check_status_of_repos "fora-request" "node_modules"
check_status_of_repos "fora-request-parser" "node_modules"
check_status_of_repos "fora-router" "node_modules"
check_status_of_repos "nodefunc-promisify" "node_modules"
