/** @jsx React.DOM */
var React = require("react");

exports.Cover = React.createClass({
    render: function() {
        if (this.props.cover) {

            classString = ['cover', this.props.cover.type].join(' ');
            imageStyle = { "background-image": "url(" + this.props.cover.image.src + ")" };
            underlayStyle = {
                background: this.props.cover.bgColor, 
                opacity: this.props.cover.opacity, 
                color: this.props.cover.foreColor
            };
            
            if (this.props.cover.type !== "inline") {
                return (
                    <div className={classString} data-field-type="cover" data-field-name={this.props.field} data-cover-format={this.props.cover.type} data-small-image={this.cover.image.small}>
                        <div className="image" style={imageStyle}>
                            <div className="underlay" style={underlayStyle}></div>
                            <div className="content-wrap">
                                { 
                                    this.props.children ? 
                                    <div className="content">
                                        this.props.children
                                    </div> 
                                    : null
                                }
                            </div>
                        </div>
                    </div>
                );
            }
            else {
                return (
                    <div className={classString} data-field-type="cover" data-field-name={this.props.field} data-cover-format={this.props.cover.type} data-small-image={this.cover.image.small}>
                        <img src={this.props.cover.image.src} />
                    </div>
                );
            }      
        }
        else {
            return (<div></div>);
        }
    }
});



