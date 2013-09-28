class Editor
    
    constructor: ->
    

        
    editRegion: =>

        editables = $('[data-editor-type]')
        editables.attr 'contenteditable', true
        editables.highlight()        
        
        element = (e for e in editables when $(e).data("editor-default"))[0]
        element = $(element)
        
        switch element.data("editor-type")
            when "text"
                ckeditor = CKEDITOR.inline element[0], { 
                    toolbar: [
                        { name: 'basicstyles', items : [ 'Bold','Italic','Underline' ] }
                    ],
                    on: {
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
                }



CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
