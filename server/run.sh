./compile.sh $1
echo Fora application starting...

cd app

cd website
if [ "$1" == "--trace" ]; then
    echo Killing node if it is running..
    killall node
    node app.js localhost 9000 &
else
    forever start app.js localhost 9000
fi
cd ..
