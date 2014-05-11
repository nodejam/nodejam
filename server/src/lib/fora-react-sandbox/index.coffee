React = require('react')

tags = [
    'div', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'span', 'a', 'em', 'strong', 'table', 'th', 'tr', 'td',
    'nav', 'section', 'article', 'header', 'footer', 'br', 'hr', 'img', 'i', 'button', 'input', 'textarea', 'script'
]

DOM = {}
for tag in tags
    do (tag) ->
        DOM[tag] = ->
            params = arguments[0]
            #   In the browser, reactjs-sandbox.js will attach event handlers to marshal the event into
            #   a sandboxed iframe. The iframe will run the untrusted component script 
            #   and we copy the modified virtual DOM back into the parent window. With this restriction 
            #   components can only modify its own virtual DOM tree and has no access outside of it.
            #if params
            #    if params.onClick
            #        params["data-reactjs-sandbox-event"] = "click"
            result = React.DOM[tag].apply React.DOM, arguments
            return result


###
renderComponentToString = (component) ->
    React.renderComponentToString component
###



createClass = (spec) ->
    old_render = spec.render
    spec.render = ->
        result = old_render.apply this, arguments
        if result
            React.Children.map result.props.children, (i) ->
                if i 
                    if i.props.onClick
                        console.log i.props.onClick
            return result
    React.createClass spec


module.exports = {
    DOM,
    createClass: createClass,
    renderComponentToString: React.renderComponentToString
}
