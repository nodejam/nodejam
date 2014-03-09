TypeUtils = require('../lib/data/typeutils')

class ForaTypeUtils extends TypeUtils

    init: =>*
        yield @buildTypeCache()
        
        

    getCacheItems: =>*
        definitions = {}
        
        for defs in [yield @getModelTypeDefinitions(), yield @getTrustedPostExtensions()]
            for name, def of defs
                definitions[name] ?= def    
        
        return definitions
        
    
    
    getModelTypeDefinitions: =>*
        #Get type definitions from models
        models = []

        fnAdd = (module) ->
            for name, model of module
                models.push model
                if model.childModels                    
                    fnAdd model.childModels

        for moduleName in ['./', './fields']
            fnAdd require moduleName

        
        definitions = {}
        
        for model in models            
            def = if typeof model.typeDefinition is "function" then model.typeDefinition() else model.typeDefinition
            def = @completeTypeDefinition(def, model)
            definitions[def.name] ?= def
        
        definitions
        
    
    
    getTrustedPostExtensions: =>*
        fs = require 'fs'
        path = require 'path'
        thunkify = require 'thunkify'
        readdir = thunkify fs.readdir
        stat = thunkify fs.stat
        readfile = thunkify fs.readFile
        
        getDirs = (dir) ->*
            dirs = []
            files = yield readdir dir
            for file, index in files
                filePath = "#{dir}/#{file}"
                entry = yield stat filePath
                if entry.isDirectory()
                    dirs.push(file)
            dirs            
        
        definitions = {}
        
        ForaModel = require('./foramodel').ForaModel
        foramodelTypeDef = {}
        
        Post = require('./post').Post
        postTypeDef = if typeof Post.typeDefinition is "function" then Post.typeDefinition() else Post.typeDefinition
        
        for ext in yield getDirs path.join __dirname, '../type-definitions/posts'
            for version in yield getDirs path.join __dirname, '../type-definitions/posts', ext
                def = JSON.parse yield readfile path.join __dirname, '../type-definitions/posts', ext, version, 'model.json'
                def.name = "#{ext}/#{version}"
                definitions["#{ext}/#{version}"] ?= def

                def.extensionType = 'builtin'
                def.realtime ?= false
                
                if def.type is 'post'
                    for field in ['collection', 'trackChanges', 'autoGenerated', 'logging']
                        def[field] = postTypeDef[field]

                    def.ctor = Post                

                    def.inheritedProperties = []
                    for k, v of postTypeDef.schema.properties
                        def.schema.properties[k] = v
                        def.inheritedProperties.push k

                    
                    for req in postTypeDef.schema.required
                        if def.schema.required.indexOf(req) is -1
                            def.schema.required.push req        

        definitions

        
        
    resolveDynamicTypeDefinition: (name) =>*
        #TODO: make sure we dont allow special characters in name, like '..'
        for x, y of TypeUtils.typeCache
            console.log "Found " + x
        console.log "Missing " + JSON.stringify name
        
        
exports.typeUtils = new ForaTypeUtils()
