React = require('react')

tags = [
    'div', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'span', 'a', 'em', 'strong', 'table', 'th', 'tr', 'td',
    'nav', 'section', 'article', 'header', 'footer', 'br', 'hr', 'img', 'i', 'button', 'input', 'textarea'
]

DOM = {}
for tag in tags
    do (tag) ->
        DOM[tag] = ->
            props = arguments[0]
            if props
                if props.html
                    props.dangerouslySetInnerHTML = { __html: props.html }
                    props.html = null
            React.DOM[tag].apply React.DOM, arguments

module.exports = {
    DOM,
    controls: {
        Cover: require('./controls/cover'),
        Page: require('./controls/page'),
        Content: require('./controls/content'),
        PostEditor: require('./controls/posteditor')
    },
    helpers: require('./helpers'),
    createClass: React.createClass
}
