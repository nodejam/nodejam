(function() {

    "use strict";

    var React = require('react'),
        ForaUI = require('fora-app-ui');

    module.exports = React.createClass({
        render: function() {
            var app = this.props.app;

            var image;

            if (app.cover) {
                var style = {
                    backgroundImage: "url(" + app.cover.image.small + ")"
                };
                image = <div className="cover" style={style}></div>;
            }
            else
                image = null;

            return (
                <li>
                    {image}
                    <div className="content">
                        <h2><a href={"/" + app.stub}>{app.name}</a></h2>
                        {
                            (function(){
                                if (app.cache && app.cache.records) {
                                    return <ul>
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
                                    </ul>;
                                }
                            })()
                        }
                    </div>
                </li>
            );
        }
    });

})();
