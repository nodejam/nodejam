class Text 

    constructor: (@editor) ->


    setup: (e) =>    
        e.attr 'contenteditable', true

        handleEmpty = =>
            if not e.text().trim()
                if e.data 'placeholder'
                    e.html "<span class=\"pre-placeholder\">&nbsp;</span><span class=\"placeholder\">#{e.data 'placeholder'}</span>"

        onFocus = =>
            placeholder = e.find('.placeholder')
    
            if placeholder.length
                placeholder.addClass 'dim'
                
                #Place caret at beginning
                range = document.createRange()
                range.selectNodeContents(e[0])
                range.collapse(true)
                selection = window.getSelection()
                selection.removeAllRanges()
                selection.addRange(range);
            
                #Remove dim from other placeholders
                $('.placeholder').not(placeholder[0]).removeClass 'dim'
            
            
                    
        e.click onFocus
        e.focus onFocus             
        e.bind 'touch', onFocus
        e.blur handleEmpty
        e.keydown =>
            if e.find('.placeholder').length
                e.empty()
            
        if e.data('field-type') is 'text'
            config = { 
                toolbar: [ { name: 'basicstyles', items : [ 'Bold', 'Italic', 'Link', 'BulletedList', 'NumberedList', 'Blockquote' ] } ],
                forcePasteAsPlainText: true
            }
            
            config.on = {
                instanceReady: (evt) => 
                    handleEmpty()
                
                    #evt.editor.focus()
                #focus: (evt) =>
                    #setTimeout (=>
                    #    editor = evt.editor
                    #    range = editor.createRange()
                    #    range.moveToElementEditStart editor.editable()
                    #    range.select()
                    #    range.scrollIntoView()), 100
            }
            
            ckeditor = CKEDITOR.inline e[0], config  
            
        
        else    
            handleEmpty()
    


    update: (post, e) =>
        e.find('.pre-placeholder,.placeholder').remove()
        switch e.data('field-type')                
            when 'heading', 'plain-text'
                post[e.data('field-name')] = e.text()
            when 'text'
                post[e.data('field-name')] = {
                    text: e.html()
                    format: 'html'
                }


window.Fora.Editing.Text = Text
