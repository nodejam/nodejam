class Item extends window.Fora.Views.BaseView

    constructor: (@forum) ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('a.join-forum').clickHandler @onJoin
        $('a.new-record').clickHandler @onNewRecord


    onJoin: (e) =>
        $.post "/api/forums/#{@forum.stub}/members", (resp) =>
            alert(JSON.stringify resp)
            #window.document.reload()
            
            
            
    onNewRecord: (e) =>
        $.post "/api/forums/#{@forum.stub}", { type: @forum.recordTypes[0], state: 'draft' }, (resp) =>
            window.location.href = "/#{@forum.stub}/#{resp.stub}?mode=edit"
        
    
            
window.Fora.Views.Forums.Item = Item
