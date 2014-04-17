/** @jsx ui.DOM */
var ui = require("fora-ui");
var Page = ui.controls.Page,
    Content = ui.controls.Content;

module.exports = ui.createClass({
    render: function() {        
        self = this;
        
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
                                                    </ul> );
                                            } else {
                                                return (
                                                    <ul className="selectable concise-icon-block float-layout cells">                                                
                                                    {function(){
                                                    for(i = 0; i < self.props.users.length; i++)
                                                        return
                                                            <li data-username={self.props.users[i].username} className="col-span span1 height2">
                                                                <div className="icon">
                                                                    <img className="seal upsize" src={self.props.users[i].image} />
                                                                </div>
                                                                <div className="text content">
                                                                    <h4>{self.props.users[i].username}</h4>
                                                                    <p className="subtext">{self.props.users[i].name}</p>
                                                                </div>
                                                            </li>
                                                    }()}                                                
                                                    </ul> );
                                            }                                                    
                                        }()}
                                    </section> );
                        }()}
 
                        <section>
                            <h2>Create a new persona...</h2>            
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
            </Page> );
    }
});
