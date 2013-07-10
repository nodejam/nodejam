utils = require '../../common/utils'
compressor = require('node-minify')

if process.argv.length > 2
    opt = process.argv[2]
    utils.log "Options: #{process.argv[2]}"

if opt isnt '--debug' and opt isnt '--trace'

    utils.log "Minifying CSS..."
    
    c = new compressor.minify {
        #type: 'no-compress',
        type: 'sqwish',
        buffer: 1000 * 1024,
        tempPath: 'tmp',
        fileIn: [
            'app/www/lib/font-awesome/css/font-awesome.css',
            'app/www/css/HINT.css',
            'app/www/css/toggle-switch.css'
        ],
        fileOut: 'app/www/js/lib.css',
        callback: (err) -> 
            if err
                utils.log(err)
            else
                utils.log 'Created lib.css'
    }    
    
    c = new compressor.minify {
        #type: 'no-compress',
        type: 'sqwish',
        buffer: 1000 * 1024,
        tempPath: 'tmp',
        fileIn: [
            'app/www/css/main.css'
        ],
        fileOut: 'app/www/js/fora.css',
        callback: (err) -> 
            if err
                utils.log(err)
            else
                utils.log 'Created fora.css'
    }    


    utils.log "Minifying JS..."

    #Already minified.
    c = new compressor.minify {
        type: 'no-compress',
        buffer: 1000 * 1024,
        tempPath: 'tmp',
        fileIn: [
            'app/www/js/lib/jquery-min.js', 
            'app/www/js/lib/angular-min.js'
        ],
        fileOut: 'app/www/js/lib-base.js',
        callback: (err) -> 
            if err
                utils.log(err)
            else
                utils.log 'Created lib-base.js'
    }    
    
    c = new compressor.minify {
        #type: 'no-compress',
        type: 'uglifyjs',
        buffer: 1000 * 1024,
        tempPath: 'tmp',
        fileIn: [
            'app/www/js/lib/jquery-cookie.js',
            'app/www/lib/bangjs/reMarked.js',            
            'app/www/lib/bangjs/jquery-drags.js',                  
            'app/www/lib/bangjs/bangjs.js',
            'app/www/lib/bangjs/bangjs-toolbar.js',
        ],
        fileOut: 'app/www/js/lib.js',
        callback: (err) -> 
            if err
                utils.log(err)
            else
                utils.log 'Created lib.js'
    }    
    
    c = new compressor.minify {
        type: 'uglifyjs',
        buffer: 1000 * 1024,
        tempPath: 'tmp',
        fileIn: [
        ],
        fileOut: 'app/www/js/fora.js',
        callback: (err) -> 
            if err
                utils.log(err)
            else
                utils.log 'Created fora.js'
    }    
else
    utils.log "Skipped minify in debug mode."            


