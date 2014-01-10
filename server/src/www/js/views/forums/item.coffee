class Item extends window.Fora.Views.BaseView

    constructor: (@forum) ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('a.join-forum').clickHandler @onJoin
        $('a.new-post').clickHandler @onNewPost
        $('button.edit').clickHandler @edit

    onJoin: (e) =>
        $.post "/api/forums/#{@forum.stub}/members", (resp) =>
            alert(JSON.stringify resp)
            #window.document.reload()
            
            
            
    onNewPost: (e) =>
        $.post "/api/forums/#{@forum.stub}", { type: @forum.postTypes[0], state: 'draft' }, (resp) =>
            window.location.href = "/#{@forum.stub}/#{resp.stub}?mode=edit"
            
            
    edit: =>
        $('button.edit').hide()
        editor = new Fora.Editing.Editor($ '.cover')
        $('button.save').clickHandler =>
            forum = editor.data()
            $.post "/api/forums/#{@forum.stub}", forum, (resp) =>
                window.location.href = "/#{@forum.stub}/#{resp.stub}?mode=edit"            
            
window.Fora.Views.Forums.Item = Item
