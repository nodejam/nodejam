React = require 'fora-react-sandbox'

render = (reactClass, props = {}, params = {}) ->*
    component = reactClass(props)
    if component.componentInit
        yield component.componentInit()

    title = props.title ? "The Fora Project"
    pageName = props.pageName ? "default-page"
    theme = props.theme ? "default-theme"
    bodyClass = "#{pageName} #{theme}"
        
    return "
        <!DOCTYPE html>
        <html>
            <head>
                <title>#{title}</title>

                <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,700|Lato:900|Crimson+Text:400,600,400italic|Oswald' rel='stylesheet' type='text/css' />
                <link href=\"/css/lib.css\" rel=\"stylesheet\" media=\"screen\" />
                <link href=\"/css/main.css\" rel=\"stylesheet\" media=\"screen\" />
                <script src=\"/js/vendor.js\"></script>
                <script src=\"/js/lib.js\"></script>
                <script src=\"/js/bundle.js\"></script>

                <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>
            </head>

            <body class=\"#{bodyClass}\">
                #{React.renderComponentToString(component)}
            </body>
        </html>"


render_DEBUG = (reactClass, props = {}, params = {}) ->*
    component = reactClass(props)
    if component.componentInit
        yield component.componentInit()

    title = props.title ? "The Fora Project"
    pageName = props.pageName ? "default-page"
    theme = props.theme ? "default-theme"
    bodyClass = "#{pageName} #{theme}"
        
    return "
        <!DOCTYPE html>
        <html>
            <head>
                <title>#{title}</title>

                <link href='http://fonts.googleapis.com/css?family=Roboto:400,400italic,700|Crimson+Text:400,600,400italic|Oswald' rel='stylesheet' type='text/css' />
                <link href=\"/vendor/components/font-awesome/css/font-awesome.css\" rel=\"stylesheet\" media=\"screen\" />
                <link href=\"/vendor/css/HINT.css\" rel=\"stylesheet\" media=\"screen\" />
                <link href=\"/vendor/css/toggle-switch.css\" rel=\"stylesheet\" media=\"screen\" />
                <link href=\"/vendor/components/medium-editor/css/medium-editor.css\" rel=\"stylesheet\" media=\"screen\" />
                <link href=\"/vendor/components/medium-editor/css/themes/default.css\" rel=\"stylesheet\" media=\"screen\" />

                <!-- CSS -->
                <link href=\"/css/main.css\" rel=\"stylesheet\" media=\"screen\" />

                <!-- 3rd Party JS -->
                <script src=\"/vendor/js/co.js\"></script>
                <script src=\"/vendor/js/markdown.js\"></script>
                <script src=\"/vendor/js/setImmediate.js\"></script>
                <script src=\"/vendor/js/regenerator-runtime.js\"></script>
                <script src=\"/vendor/js/react.js\"></script>

                <!-- Browserified JS with Debug Info -->
                <script src=\"/js/bundle.js\"></script>

                <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>
            </head>

            <body class=\"#{bodyClass}\">
                #{React.renderComponentToString(component)}
            </body>
        </html>"


module.exports = {
    render,
    render_DEBUG
}
