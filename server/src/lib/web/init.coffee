React = require 'fora-react-sandbox'
RequestParser = require('fora-webrequestparser')
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()
conf = require '../../conf'


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



module.exports = (app) ->
    app.use (next) ->*
        if @method is 'POST' or @method is 'PUT' or @method is 'PATCH'
            @parser =  new RequestParser(@, typeUtils)

        network = (n for n in conf.networks when n.domains.indexOf(@host) isnt -1)
        if network.length
            @network = network[0]
        else
            throw new Error "Invalid network"
            
        @render = render
            
        yield next
        
    app.on 'error', (err) ->
        console.log(err)
            
