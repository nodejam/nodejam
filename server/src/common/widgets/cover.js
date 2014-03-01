/** @jsx React.DOM */
var React = require("react");

exports.Cover = React.createClass({
    render: function() {
        if (this.props.cover) {
            if (this.props.cover.type !== "inline") {
            
                classString = ['cover', this.props.cover.type].join(' ');

                style = []
                if(this.props.cover.bgColor)
                    style.push('background:' + cover.bgColor);
                if(cover.opacity)
                    style.push('opacity:' + cover.opacity);
                if(cover.foreColor)
                    style.push('color:' + cover.foreColor);
                styleString = style.join(';');
                    
                <div className={classString} data-field-type="cover" data-field-name={this.props.field} data-cover-format={this.props.cover.type} data-small-image={this.cover.image.small}>
                    <div className="image" style={"background-image:url(" + this.props.cover.image.src + ")"}>
                        <div className="underlay" style={styleString}></div>
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
            }                
        }
    }
});



