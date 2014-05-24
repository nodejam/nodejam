/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');
var Models = require('../../../models');

var Page = ForaUI.Page,
    Content = ForaUI.Content;

module.exports = React.createClass({displayName: 'exports',
    render: function() {        
        self = this;
        
        if (!self.props.users.length)
            createMessage = "Create an identity";
        else
            createMessage = "Or create another identity";
        return (
            Page(null, 
                Cover( {cover:self.props.cover, coverContent:self.props.coverContent} ),
                Content(null, 
                    React.DOM.div( {className:"content-area item small"}, 

                        function() {
                            if (self.props.users)
                                return (
                                    React.DOM.section(null, 
                                        React.DOM.h2(null, "Sign in as"),                                        
                                        function() {
                                            if (self.props.users.length === 1) {
                                                return (
                                                    React.DOM.ul( {className:"selectable icon-block row-layout cells"}, 
                                                        React.DOM.li( {'data-username':self.props.users[0].username}, 
                                                            React.DOM.div( {className:"icon"}, 
                                                                React.DOM.img( {className:"seal upsize", src:self.props.users[0].image} )
                                                            ),
                                                            React.DOM.div( {className:"text content"}, 
                                                                React.DOM.h3(null, self.props.users[0].name),
                                                                React.DOM.p(null, self.props.users[0].about)
                                                            )
                                                        )
                                                    ) );
                                            } else {
                                                return (
                                                    React.DOM.ul( {className:"selectable concise-icon-block float-layout cells"},                                                 
                                                    function() {
                                                        return self.props.users.map(function(user) {
                                                            return (
                                                                React.DOM.li( {'data-username':user.username, className:"col-span span1 height2"}, 
                                                                    React.DOM.div( {className:"icon"}, 
                                                                        React.DOM.img( {className:"seal upsize", src:user.image} )
                                                                    ),
                                                                    React.DOM.div( {className:"text content"}, 
                                                                        React.DOM.h4(null, user.username),
                                                                        React.DOM.p( {className:"subtext"}, user.name)
                                                                    )
                                                                ) );
                                                        });
                                                    }()                                                
                                                    ) );
                                            }                                                    
                                        }()
                                    ) );
                        }(),
 
                        React.DOM.section(null, 
                            React.DOM.h2(null, createMessage),            
                            React.DOM.div( {className:"icon-block content", id:"create-user-form"} , 
                                React.DOM.div( {className:"icon picture", 'data-src':"/public/images/0/user.jpg", 'data-small':"/public/images/0/user_t.jpg"}, 
                                    React.DOM.img( {className:"seal upsize", src:"/images/user-default.png"} ),React.DOM.br(null ),
                                    React.DOM.a( {href:"#"}, "change")
                                ),
                                React.DOM.div( {className:"text font-content textsize-XL"}, 
                                    React.DOM.ul( {className:"lined-fields"}, 
                                        React.DOM.li( {className:"username", 'data-suggestion':this.props.nickname}
                                        ),
                                        React.DOM.li( {className:"fullname"}
                                        ),
                                        React.DOM.li( {className:"about"}
                                        )
                                    ),
                                    React.DOM.p(null, 
                                        React.DOM.button( {className:"create"}, "Create ", React.DOM.i( {className:"fa fa-caret-right"}))
                                    )
                                )
                            )                           
                        )
                        
                    )                
                )
            ) );
    }
});

