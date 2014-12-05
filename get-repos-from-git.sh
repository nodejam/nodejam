echo Fetching dev repos related to Fora

get_repos_from_git() {
    curdir=`pwd`
    proj=$1
    basedir=$2
    if [ ! -d $basedir/$proj/.git ]; then
        echo cloning $basedir/$proj
        rm -rf $basedir/$proj
        git clone https://github.com/jeswin/$proj $basedir/$proj
        cd $basedir/$proj
        npm install
        cd $curdir
    else
        echo $basedir/$proj is already a git repo
    fi
}

get_repos_from_git "fora-build" "node_modules"
get_repos_from_git "fora-data-utils" "server/node_modules"
get_repos_from_git "fora-db" "server/node_modules"
get_repos_from_git "fora-db-backend-mongodb" "server/node_modules"
get_repos_from_git "fora-extensions-service" "server/node_modules"
get_repos_from_git "fora-request" "server/node_modules"
get_repos_from_git "fora-request-parser" "server/node_modules"
get_repos_from_git "fora-router" "server/node_modules"
get_repos_from_git "fora-types-service" "server/node_modules"
get_repos_from_git "fora-validator" "server/node_modules"
