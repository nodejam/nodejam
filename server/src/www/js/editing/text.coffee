class Text 

    constructor: (@e, @editor) ->


    setup: =>
        @e.attr 'contenteditable', true

        onFocus = =>
            placeholder = @e.find('.placeholder')
    
            if placeholder.length
                placeholder.addClass 'dim'                
                #Place caret at beginning
                range = document.createRange()
                range.selectNodeContents(e[0])
                range.collapse(true)
                selection = window.getSelection()
                selection.removeAllRanges()
                selection.addRange(range);
            
        @e.click onFocus
        @e.focus onFocus             
        @e.bind 'touch', onFocus
        @e.blur @handleEmpty
        
        @e.keydown =>
            if @e.find('.placeholder').length
                @e.empty()

        if @e.data('field-type') is 'text'
             editor = new MediumEditor(@e)

        else    
            @handleEmpty()
    


    update: (post) =>
        @e.find('.placeholder').remove()
        switch @e.data('field-type')                
            when 'heading', 'plain-text'
                post[@e.data('field-name')] = @e.text()
            when 'text'
                post[@e.data('field-name')] = {
                    text: @e.html()
                    format: 'html'
                }
        @handleEmpty()
        

        
    handleEmpty: =>
            if @e.text().trim()
                if @e.data 'placeholder'
                    placeholder = @e.find('.placeholder')            
                    if placeholder.length
                        placeholder.removeClass 'dim'
            else
                @e.html "<span class=\"placeholder\">#{@e.data 'placeholder'}</span>"

window.Fora.Editing.Text = Text
