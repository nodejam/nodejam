class Editor
    
    constructor: (@container) ->
        @imageField = new Fora.Editing.Image @
        @textField = new Fora.Editing.Text @
        
        editables = @container.find('[data-field-type]')
        editables.highlight()        
    
        for e in editables
            do (e) =>
                e = $ e
                @getField(e.data 'field-type').setup e        
        


    update: (post = {}) =>
        for e in @container.find('[data-field-type]')
            e = $ e
            @getField(e.data 'field-type').update post, e                
        @flatten post, [], {}
                    
                    
    
    flatten: (post, prefix, acc) =>
        for f, v of post
            if v and typeof v isnt "function"
                if typeof v is "object"
                    @flatten v, prefix.concat(f), acc
                else
                    acc[prefix.concat(f).join('_')] = v
        acc
        
        

    getRandomElementId: =>
        "e#{Fora.uniqueId()}"



    getField: (type) =>
        switch type
            when 'image'
                @imageField                
            when 'heading', 'text', 'plain-text'
                @textField
    


CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
