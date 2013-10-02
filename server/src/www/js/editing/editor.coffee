class Editor
    
    constructor: ->
    

        
    editPage: (element) =>
        element = $(element)
        
        editables = $('[data-editor-type]')
        editables.attr 'contenteditable', true
        editables.highlight()        
    
        for e in editables
            do (e) =>
                e =  $(e)
                switch e.data('editor-type')                
                    when 'title'
                        @setupTextElement e
                                            
                    when 'text'            
                        @setupTextElement e
                                    
                        config = { 
                            toolbar: [ { name: 'basicstyles', items : [ 'Bold','Italic' ] } ]
                        }
                        
                        if element[0] is e[0]
                            config.on = {
                                instanceReady: (evt) => 
                                    evt.editor.focus()
                                focus: (evt) =>
                                    setTimeout (=>
                                        editor = evt.editor
                                        range = editor.createRange()
                                        range.moveToElementEditStart editor.editable()
                                        range.select()
                                        range.scrollIntoView()), 100
                            }
                        
                        ckeditor = CKEDITOR.inline e[0], config        

                
    
    setupTextElement: (e) =>
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
        
        

CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
