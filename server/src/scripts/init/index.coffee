co = require 'co'
conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
utils = require '../../lib/utils'
fs = require 'fs'
path = require 'path'
fsutils = require '../../common/fsutils'
typeUtils = require('../../models/foratypeutils').typeUtils

#create directories
today = Date.now()
for p in (fsutils.getBasePath(x) for x in ['assets', 'images', 'originalimages'])
    for i in [0..999] by 1    
        do (p) ->
            do (i) ->
                newPath = path.join p, "#{i}"
                fs.exists newPath, (exists) ->
                    if not exists
                        fs.mkdir newPath, ->
                        utils.log "Created #{newPath}"
                    else
                        utils.log "#{newPath} exists"
    
#Ensure indexes.
(co ->*
    yield typeUtils.buildTypeCache()
    indexes = {}
    for name, typeDefinition of typeUtils.getTypeCache()
        if typeDefinition.indexes
            indexes[typeDefinition.collection] = typeDefinition.indexes
    yield db.setupIndexes indexes
)()   

setTimeout (-> process.exit()), 5000
