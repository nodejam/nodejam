class Editor
    
    constructor: (@typeDefinition) ->
        @editables = $('[data-field-type]')
        @imageField = new Fora.Editing.Image @
        @textField = new Fora.Editing.Text @
        
        
        
    editPage: =>
        @editables.highlight()        
    
        for e in @editables
            do (e) =>
                e = $ e
                @getField(e.data 'field-type').setup e



    update: (record = {}) =>
        for e in @editables
            e = $ e
            @getField(e.data 'field-type').update record, e
        record
                    


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
