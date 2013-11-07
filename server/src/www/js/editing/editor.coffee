class Editor
    
    constructor: (@typeDefinition) ->
        @imageField = new Fora.Editing.Image @
        @textField = new Fora.Editing.Text @
        
        
        
    editPage: =>
        editables = $('[data-field-type]')
        editables.highlight()        
    
        for e in editables
            do (e) =>
                e = $ e
                @getField(e.data 'field-type').setup e



    update: (record = {}) =>
        for e in $('[data-field-type]')
            e = $ e
            @getField(e.data 'field-type').update record, e                
        @flatten record, [], {}
                    
                    
    
    flatten: (record, prefix, acc) =>
        for f, v of record
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
            when 'heading', 'text'
                @textField
    


CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
