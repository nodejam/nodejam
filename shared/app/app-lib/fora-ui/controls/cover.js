/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        cover = this.props.cover;
        
        if (cover) {
            if (!cover.type)
               cover.type = "auto-cover";
                
            classString = ['cover', cover.type].join(' ');
            imageStyle = { "background-image": "url(" + cover.image.src + ")" };
            underlayStyle = {
                background: cover.bgColor, 
                opacity: cover.opacity, 
                color: cover.foreColor
            };
            
            if (cover.type !== "inline-cover") {
                return (
                    React.DOM.div( {className:classString, 'data-field-type':"cover", 'data-field-name':this.props.field, 'data-cover-format':cover.type, 'data-small-image':cover.image.small}, 
                        React.DOM.div( {className:"image", style:imageStyle}, 
                            React.DOM.div( {className:"underlay", style:underlayStyle}),
                            React.DOM.div( {className:"content-wrap", dangerouslySetInnerHTML:{__html: this.props.coverContent}}
                            )
                        )
                    )
                );
            }
            else {
                return (
                    React.DOM.div( {className:classString, 'data-field-type':"cover", 'data-field-name':this.props.field, 'data-cover-format':cover.type, 'data-small-image':cover.image.small}, 
                        React.DOM.img( {src:cover.image.src} )
                    )
                );
            }      
        }
        else {
            return (React.DOM.div(null));
        }
    }
});
