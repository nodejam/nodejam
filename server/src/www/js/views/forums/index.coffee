class Index extends Fora.Views.BaseView

    constructor: ->
        super()        
        $(document).ready @attachEvents

        
    attachEvents: =>
        $('.collection-items li a').clickHandler ->
            window.location.href = $(@).attr 'href'
            false
            
        $('.collection-items li').clickHandler @gotoPost


    
    gotoPost: ->
        url = $(this).data('url')
        window.location.href = url
        
                          
window.Fora.Views.Forums.Index = Index
