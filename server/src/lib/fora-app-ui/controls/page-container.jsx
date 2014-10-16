/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react'),
        SiteOptions = require('./site-options');

    module.exports = React.createClass({
        getInitialState: function() {
            return { page: this.props.page };
        },

        headerOnClick: function() {
            this.setState({ showSiteOptions: true });
        },

        closeHandler: function() {
            this.setState({ showSiteOptions: false });
        },

        render: function() {

            return (
                <div className="page-container">
                    {
                        !this.state.showSiteOptions ?
                            <header className="site" onClick={this.headerOnClick}>
                                <a href="#" className="logo">
                                    Fora
                                </a>
                            </header>
                            : undefined
                    }
                    {
                        this.state.showSiteOptions ?
                        <SiteOptions closeHandler={this.closeHandler} />
                        : undefined
                    }
                    {this.state.page}
                </div>
            );
        }
    });

})();
