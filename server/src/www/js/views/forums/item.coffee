class Item extends window.Fora.Views.BaseView

    constructor: (@forum) ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('a.join-forum').clickHandler @onJoin
        $('a.new-post').clickHandler @onNewPost


    onJoin: (e) =>
        $.post "/api/forums/#{@forum.stub}/members", (resp) =>
            alert(JSON.stringify resp)
            #window.document.reload()
            
            
            
    onNewPost: (e) =>
        $.post "/api/forums/#{@forum.stub}", { type: @forum.postTypes[0], state: 'draft' }, (resp) =>
            window.location.href = "/#{@forum.stub}/#{resp.stub}?mode=edit"
        
    
            
window.Fora.Views.Forums.Item = Item
