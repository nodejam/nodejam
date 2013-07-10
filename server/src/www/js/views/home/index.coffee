class IndexView extends Fora.Views.BaseView

    constructor: ->
        super()        
        $(document).ready @attachEvents

        
    attachEvents: =>
        $('.collection-items li a').click ->
            window.location.href = $(@).attr 'href'
            false
            
        $('.collection-items li').click @gotoPost


    
    gotoPost: ->
        url = $(this).data('url')
        window.location.href = url
        false  
        
                          
window.Fora.Views.Home.IndexView = IndexView
