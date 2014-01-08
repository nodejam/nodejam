class Editor
    
    constructor: (@container) ->
        editables = @container.find('[data-field-type]')
        editables.highlight()        
    
        for e in editables
            do (e) =>
                e = $ e
                ctor = @getControl(e.data 'field-type')
                control = new ctor(e, @)
                e.data 'control', control
                control.setup()
        


    update: (post = {}) =>
        for e in @container.find('[data-field-type]')
            e = $ e
            e.data('control').update post
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



    getControl: (type) =>
        switch type
            when 'image'
                Fora.Editing.Image                
            when 'heading', 'text', 'plain-text'
                Fora.Editing.Text
            when 'selectable'
                Fora.Editing.Selectable
    


CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
