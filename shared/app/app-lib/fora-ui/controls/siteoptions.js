/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        return (
            React.DOM.div( {className:"site-options"},     
                React.DOM.ul(null, 
                    React.DOM.li(null, React.DOM.a( {href:"/"}, React.DOM.i( {className:"fa fa-home"}),"Home")),  
                    React.DOM.li(null, React.DOM.a( {href:"/forums"}, React.DOM.i( {className:"fa fa-list"}),"Forums")),              
                    React.DOM.li( {className:"account"})  
                ),
                React.DOM.div( {className:"transparent-overlay"}
                )
            )
        );        
    }
});

