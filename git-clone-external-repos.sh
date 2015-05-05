echo Fetching dev repos related to Fora

runtask() {
    curdir=`pwd`
    proj=$1
    basedir=$2
    if [ ! -d $basedir/$proj/.git ]; then
        echo cloning $basedir/$proj
        echo ----------------------
        rm -rf $basedir/$proj
        git clone https://github.com/jeswin/$proj $basedir/$proj
        cd $basedir/$proj
        npm install
        cd $curdir
    else
        echo $basedir/$proj is already a git repo
    fi
}

echo ....................................
echo Git Clone
echo ....................................

runtask "fora-template-blog" "node_modules"

runtask "ceramic-backend-mongodb" "node_modules/fora-template-blog/node_modules"
runtask "ceramic-backend-nedb" "node_modules/fora-template-blog/node_modules"

runtask "isotropy-browser-mode" "node_modules/fora-template-blog/node_modules";
runtask "isotropy" "node_modules/fora-template-blog/node_modules/isotropy-browser-mode/node_modules";
runtask "isotropy-browser-request" "node_modules/fora-template-blog/node_modules/isotropy-browser-mode/node_modules";

runtask "isotropy-koa-mode" "node_modules/fora-template-blog/node_modules";
runtask "isotropy" "node_modules/fora-template-blog/node_modules/isotropy-koa-mode/node_modules";
