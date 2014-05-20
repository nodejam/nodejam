
class Index

    constructor: (@data) ->
        @data.editorsPicks = (new Fora.Models.Post(p) for p in data.editorsPicks) 
        @data.featured = (new Fora.Models.Post(p) for p in data.featured) 
        
        require ['/shared/website/views/home/index.js'], @render
        
        
    
    render: (IndexView) =>
        (co =>*
            component = IndexView(@data)
            yield component.type.componentInit(component)
            React.renderComponent component, $('#page-container')[0]
        )()
    

module.exports = Index        
