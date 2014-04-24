React = require('react')

tags = [
    'div', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'span', 'a', 'em', 'strong', 'table', 'th', 'tr', 'td',
    'nav', 'section', 'article', 'header', 'footer', 'br', 'hr', 'img', 'i', 'button', 'input', 'textarea'
]

DOM = {}
for tag in tags
    do (tag) ->
        DOM[tag] = ->
            params = arguments[0]
            #   In the browser, reactjs-sandbox.js will attach event handlers to marshal the event into
            #   an iframe in a different domain (hence sandboxed). The iframe will run the full component script (over ReactJS), 
            #   and we copy the modified virtual DOM back into the parent window. With this restriction 
            #   components can only modify the component's own DOM tree and has no access outside of it.
            if params
                if params.onClick
                    params["data-reactjs-sandbox-event"] = "click"
            result = React.DOM[tag].apply React.DOM, arguments
            return result


module.exports = {
    DOM,
    createClass: React.createClass
}
