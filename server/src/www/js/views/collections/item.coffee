class Item extends window.Fora.Views.BaseView

    constructor: (@collection) ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('a.join-collection').clickHandler @onJoin
        $('a.new-record').clickHandler @onNewRecord


    onJoin: (e) =>
        $.post "/api/collections/#{@collection.stub}/members", (resp) =>
            alert(JSON.stringify resp)
            #window.document.reload()
            
            
            
    onNewRecord: (e) =>
        $.post "/api/collections/#{@collection.stub}", { type: @collection.recordTypes[0], state: 'new' }, (resp) =>
            window.location.href = "/#{@collection.stub}/#{resp.stub}?mode=edit"
        
    
            
window.Fora.Views.Collections.Item = Item
