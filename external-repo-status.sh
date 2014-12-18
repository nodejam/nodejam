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

check_status_of_repos "fora-build" "node_modules"
check_status_of_repos "fora-data-utils" "node_modules"
check_status_of_repos "fora-db" "node_modules"
check_status_of_repos "fora-db-backend-mongodb" "node_modules"
check_status_of_repos "fora-extensions-service" "node_modules"
check_status_of_repos "fora-request" "node_modules"
check_status_of_repos "fora-request-parser" "node_modules"
check_status_of_repos "fora-router" "node_modules"
check_status_of_repos "fora-types-service" "node_modules"
check_status_of_repos "fora-validator" "node_modules"
