/** @jsx React.DOM */
React = require("react")

var Article = React.createClass({
  render: function() {
    return (
        <Page theme="theme">
            <Cover field="cover" />
            <Heading size="1" field="title" />
            <Author field="author" />
            <Html field="content" />
        </Page>
    );
  }
});
