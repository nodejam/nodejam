React = require 'fora-react-sandbox'

makeScript = (src) ->
    "<script src=\"#{src}\"></script>"

makeLink = (href, rel="stylesheet", media="screen", type = "text/css") ->
    "<link href=\"#{href}\" rel=\"#{rel}\" media=\"#{media}\" />"


deps = {
        styles: [
            'http://fonts.googleapis.com/css?family=Open+Sans:400,700|Lato:900|Crimson+Text:400,600,400italic|Oswald',
            '/css/lib.css',
            '/css/main.css'
        ],
        
        scripts: [
            '/js/vendor.js',
            '/js/lib.js',
            '/js/bundle.js'
        ]
    }
     
 
debug_deps ={
        styles: [
            'http://fonts.googleapis.com/css?family=Open+Sans:400,700|Lato:900|Crimson+Text:400,600,400italic|Oswald',
            '/vendor/components/font-awesome/css/font-awesome.css',
            '/vendor/css/HINT.css',
            '/vendor/css/toggle-switch.css',
            '/vendor/components/medium-editor/css/medium-editor.css',
            '/vendor/components/medium-editor/css/themes/default.css',
            '/css/main.css'
        ],
        
        scripts: [
            '/vendor/js/co.js',
            '/vendor/js/markdown.js',
            '/vendor/js/setImmediate.js',
            '/vendor/js/regenerator-runtime.js',
            '/vendor/js/react.js',
            '/js/bundle.js'
        ]
    }

render = (debug) ->
    (reactClass, pagePath, props = {}, params = {}) ->*
        component = reactClass(props)
        if component.componentInit
            yield component.componentInit()

        title = props.title ? "The Fora Project"
        pageName = props.pageName ? "default-page"
        theme = props.theme ? "default-theme"
        bodyClass = "#{pageName} #{theme}"
 
        d = if debug then debug_deps else deps
        depsHtml = (makeLink(x) for x in d.styles).concat(makeScript(x) for x in d.scripts).join('')
        
        if params.scripts
            depsHtml += (makeScript(x) for x in params.scripts).join("")
        
        if params.javascript
            depsHtml += "<script>#{params.javascript}</script>"
            
        depsHtml += "
            <script>
                app.initPage(\"#{pagePath}\", #{JSON.stringify(props)});
            </script>"
        
        return "
            <!DOCTYPE html>
            <html>
                <head>
                    <title>#{title}</title>
                    #{depsHtml}
                    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>
                </head>

                <body class=\"#{bodyClass}\">
                    <!-- header -->
                    <header class=\"site\">
                        <a href=\"#\" class=\"logo\">
                            Fora
                        </a>
                    </header>
                    <div class=\"page-container\">
                    #{React.renderComponentToString(component)}
                    </div>
                </body>
            </html>"


module.exports = {
    render: render(false),
    render_DEBUG: render(true)
}


