
class Index

     constructor: (data) ->

        require ['/shared/website/views/home/index.js'], (IndexView) ->
            component = IndexView(data)
            React.renderComponent component, $('.single-section-page')[0]

        
window.Fora.Views.Home.Index = Index
