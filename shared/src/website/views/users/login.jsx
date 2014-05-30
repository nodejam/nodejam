/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');
var Models = require('../../../models');

var Page = ForaUI.Page,
    Content = ForaUI.Content;

module.exports = React.createClass({
    render: function() {        
        self = this;
        
        if (!self.props.users.length)
            createMessage = "Create an identity";
        else
            createMessage = "Or create another identity";
        return (
            <Page>
                <Cover cover={self.props.cover} coverContent={self.props.coverContent} />
                <Content>
                    <div className="content-area item small">

                        {function() {
                            if (self.props.users)
                                return (
                                    <section>
                                        <h2>Sign in as</h2>                                        
                                        {function() {
                                            if (self.props.users.length === 1) {
                                                return (
                                                    <ul className="selectable icon-block row-layout cells">
                                                        <li data-username={self.props.users[0].username}>
                                                            <div className="icon">
                                                                <img className="seal upsize" src={self.props.users[0].image} />
                                                            </div>
                                                            <div className="text content">
                                                                <h3>{self.props.users[0].name}</h3>
                                                                <p>{self.props.users[0].about}</p>
                                                            </div>
                                                        </li>
                                                    </ul> 
                                                );
                                            } else {
                                                return (
                                                    <ul className="selectable concise-icon-block float-layout cells">                                                
                                                    {function() {
                                                        return self.props.users.map(function(user) {
                                                            return (
                                                                <li data-username={user.username} className="col-span span1 height2">
                                                                    <div className="icon">
                                                                        <img className="seal upsize" src={user.image} />
                                                                    </div>
                                                                    <div className="text content">
                                                                        <h4>{user.username}</h4>
                                                                        <p className="subtext">{user.name}</p>
                                                                    </div>
                                                                </li> 
                                                            );
                                                        });
                                                    }()}                                                
                                                    </ul> 
                                                );
                                            }                                                    
                                        }()}
                                    </section> 
                                );
                        }()}
 
                        <section>
                            <h2>{createMessage}</h2>            
                            <div className="icon-block content" id="create-user-form" >
                                <div className="icon picture" data-src="/public/images/0/user.jpg" data-small="/public/images/0/user_t.jpg">
                                    <img className="seal upsize" src="/images/user-default.png" /><br />
                                    <a href="#">change</a>
                                </div>
                                <div className="text font-content textsize-XL">
                                    <ul className="lined-fields">
                                        <li className="username" data-suggestion={this.props.nickname}>
                                        </li>
                                        <li className="fullname">
                                        </li>
                                        <li className="about">
                                        </li>
                                    </ul>
                                    <p>
                                        <button className="create">Create <i className="fa fa-caret-right"></i></button>
                                    </p>
                                </div>
                            </div>                           
                        </section>
                        
                    </div>                
                </Content>
            </Page> 
        );
    }
});

