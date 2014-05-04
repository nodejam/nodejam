
class Index

    constructor: (@data) ->
        require ['/shared/website/views/home/index.js'], @render
        
        
    
    render: (IndexView) ->
        (co ->*
            component = IndexView(@data)
            yield component.componentInit()
            React.renderComponent component, $('.single-section-page')[0]
        )()
    

        
window.Fora.Views.Home.Index = Index
