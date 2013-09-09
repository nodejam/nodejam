class Item extends window.Fora.Views.BaseView

    constructor: (@forum) ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('a.join-forum').click @onJoin



    onJoin: (e) =>
        $.post "/api/forums/#{@forum}/members", (resp) =>
            alert(JSON.stringify resp)
            #window.document.reload()
        
    
            
window.Fora.Views.Forums.Item = Item
