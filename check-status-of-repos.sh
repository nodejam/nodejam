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
check_status_of_repos "fora-data-utils" "server/node_modules"
check_status_of_repos "fora-db" "server/node_modules"
check_status_of_repos "fora-db-backend-mongodb" "server/node_modules"
check_status_of_repos "fora-extensions-service" "server/node_modules"
check_status_of_repos "fora-request" "server/node_modules"
check_status_of_repos "fora-request-parser" "server/node_modules"
check_status_of_repos "fora-router" "server/node_modules"
check_status_of_repos "fora-types-service" "server/node_modules"
check_status_of_repos "fora-validator" "server/node_modules"
check_status_of_repos "fora-build" "server/node_modules"
check_status_of_repos "fora-build" "server/node_modules"
check_status_of_repos "fora-build" "server/node_modules"
