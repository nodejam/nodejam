class Editor
    
    constructor: (@typeDefinition) ->
        @editables = $('[data-field-type]')
                        

        
    editPage: =>
        @editables.highlight()        
    
        for e in @editables
            do (e) =>
                e =  $(e)
                switch e.data('field-type')                
                    when 'image'
                        @setupImage e
                        
                    when 'title'
                        @setupTextElement e
                                            
                    when 'text'            
                        @setupTextElement e
                                    
                        config = { 
                            toolbar: [ { name: 'basicstyles', items : [ 'Bold','Italic' ] } ]
                        }
                        
                        config.on = {
                            instanceReady: (evt) => 
                                evt.editor.focus()
                            focus: (evt) =>
                                #setTimeout (=>
                                #    editor = evt.editor
                                #    range = editor.createRange()
                                #    range.moveToElementEditStart editor.editable()
                                #    range.select()
                                #    range.scrollIntoView()), 100
                        }
                        
                        ckeditor = CKEDITOR.inline e[0], config        



    setupImage: (e) =>
        if not $('.image img').length
            $('.image').html '<p class="editor-option add-picture"><i class="icon-picture"></i> <a href="#">Add a picture</a></p>'
                        
    
    setupTextElement: (e) =>    
        e.attr 'contenteditable', true

        handleEmpty = =>
            if not e.text().trim() and e.data 'placeholder'
                e.addClass 'placeholder'
                e.html e.data 'placeholder'

        e.keypress =>
            if e.hasClass 'placeholder'
                e.removeClass 'placeholder'
                e.html ''
        
        e.blur =>
            handleEmpty e
            
        handleEmpty e
        
        
        
    update: (record = {}) =>
        for e in @editables
            e =  $(e)
            switch e.data('field-type')                
                when 'title'
                    record[e.data('field-name')] = e.text()
                when 'text'
                    field = e.data('field-name')
                    record[field + '_text'] = e.html()
                    record[field + '_format'] = 'html'
        record
                    

CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
