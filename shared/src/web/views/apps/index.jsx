/** @jsx React.DOM */
(function() {
    "use strict"

    var React = require('react'),
        ForaUI = require('fora-ui'),
        ExtensionLoader = require('fora-extensions').Loader,
        Models = require('fora-app-models');

    var Page = ForaUI.Page,
        Content = ForaUI.Content;

    module.exports = React.createClass({
        render: function() {
            createItem = function(app) {
                if (app.cover) {
                    style = {
                        backgroundImage: "url(" + app.cover.image.small + ")"
                    };
                    image = <div className="image" style={style}></div>
                }
                else
                    image = null;

                return (
                    <li className="col-span span5">
                        {image}
                        <article>
                            <h2><a href={"/" + app.stub}>{app.name}</a></h2>
                            <ul>
                                {
                                    app.cache.records.map(function(record) {
                                        return (
                                            <li>
                                                <a href={"/" + app.stub + "/" + record.stub}>{record.title}</a><br />
                                                <span className="subtext">{record.createdBy.name}</span>
                                            </li>
                                        );
                                    })
                                }
                            </ul>
                        </article>
                    </li>
                );
            };

            return (
                <Page>
                    <Content>
                        <nav>
                            <ul>
                                <li className="selected">
                                    Records
                                </li>
                                <li>
                                    <a href="/s">Forums</a>
                                </li>
                            </ul>
                        </nav>
                        <div className="content-area wide">
                            <ul className="articles card-view">
                                {this.props.s.map(createItem)}
                            </ul>
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
