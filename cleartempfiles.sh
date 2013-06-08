if [ $NODE_ENV == "development" ]
then
    find . -name "*.*~" | xargs rm
else
    echo "clearTempFiles.sh can only be run in development."
fi    
