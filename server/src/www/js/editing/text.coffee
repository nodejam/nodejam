class Text 

    constructor: (@editor) ->


    setup: (e) =>    
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

        if e.data('field-type') is 'text'
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
            


    update: (e, record) =>
        switch e.data('field-type')                
            when 'heading'
                record[e.data('field-name')] = e.text()
            when 'text'
                field = e.data('field-name')
                record[field + '_text'] = e.html()
                record[field + '_format'] = 'html'


window.Fora.Editing.Text = Text
