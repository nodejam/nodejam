React = require('react')

tags = [
    'div', 'p', 'h1', 'h2', 'h3', 'ul', 'ol', 'li', 'span', 'a', 'em', 'strong', 'table', 'th', 'tr', 'td',
    'nav', 'section', 'article', 'header', 'footer', 'br', 'hr', 'img'
]

for tag in tags
    do (tag) ->
        module.exports[tag] = ->
            React.DOM[tag].apply React.DOM, arguments
