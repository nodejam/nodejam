./compile.sh $1
echo Lappd application starting...

cd app

cd website
if [ "$1" == "--trace" ]; then
    node app.js localhost 9000 &
else
    forever start app.js localhost 9000
fi
cd ..
