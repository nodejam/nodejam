class InlineEditor
    
    constructor: ->
    
    

    editPage: =>
        CKEDITOR.disableAutoInline = true
        for element in $('[data-editor]')
            params = {}
            for p in $(element).data('editor').split(',')
                kv = p.split ':'
                params[kv[0]] = kv[1]
            
            switch params.type
                when 'text'
                    CKEDITOR.inline element


window.Fora.Editors.InlineEditor = InlineEditor
