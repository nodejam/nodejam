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

runtask "ceramic-backend-mongodb" "node_modules"
runtask "ceramic-backend-nedb" "node_modules"
runtask "fora-template-blog" "node_modules"

runtask "ceramic-backend-mongodb" "node_modules/fora-template-blog/node_modules"
runtask "ceramic-backend-nedb" "node_modules/fora-template-blog/node_modules"
runtask "isotropy-xml-http-request" "node_modules/fora-template-blog/node_modules"

runtask "isotropy-browser-mode" "node_modules/fora-template-blog/node_modules";
runtask "isotropy" "node_modules/fora-template-blog/node_modules/isotropy-browser-mode/node_modules";
runtask "isotropy-koa-context-in-browser" "node_modules/fora-template-blog/node_modules/isotropy-browser-mode/node_modules";
runtask "isotropy-request-response-in-browser" "node_modules/fora-template-blog/node_modules/isotropy-browser-mode/node_modules/isotropy-koa-context-in-browser/node_modules";

runtask "isotropy-koa-mode" "node_modules/fora-template-blog/node_modules";
runtask "isotropy" "node_modules/fora-template-blog/node_modules/isotropy-koa-mode/node_modules";

runtask "isotropy-dev-mode" "node_modules/fora-template-blog/node_modules";
runtask "isotropy" "node_modules/fora-template-blog/node_modules/isotropy-dev-mode/node_modules";
runtask "koa-in-browser" "node_modules/fora-template-blog/node_modules/isotropy-dev-mode/node_modules";
runtask "isotropy-request-response-in-browser" "node_modules/fora-template-blog/node_modules/isotropy-dev-mode/node_modules/koa-in-browser/node_modules";
