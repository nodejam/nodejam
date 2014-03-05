class Text 

    constructor: (@e, @fieldName, @fieldProperties, @binding, @editor) ->
        @setup()



    setup: =>
        @e.attr 'contenteditable', true

        @e.click @onFocus
        @e.focus @onFocus             
        @e.bind 'touch', @onFocus
        @e.blur @onBlur        
        @e.keydown @onKeydown

        @state = { 
            event: "blur",
            empty: @isEmpty()
        }

        if @binding.type is 'text'
             new MediumEditor @e
        else    
            @evalControlState()
            
    
    
    onFocus: =>
        @state.event = "focus"
        @state.empty = @isEmpty()
        @evalControlState()


    
    onKeydown: =>        
        @state.event = "keypress"        
        @state.empty = false
        @evalControlState()

        
    
    onBlur: =>
        @state.event = "blur"
        @state.empty = @isEmpty()
        @evalControlState()



    isEmpty: =>
        if @e.clone().children('.placeholder').remove().end().text().trim() then false else true



    evalControlState: =>
        console.log @state
        if @state.event is 'blur' 
            if @state.empty
                @e.html "<span class=\"placeholder\">#{@binding.placeholder}</span>"
            else
                @e.find('.placeholder').removeClass 'dim'
                
        if @state.event is 'focus'
            if @state.empty
                placeholder = @e.find('.placeholder')
                if placeholder.length
                    placeholder.addClass 'dim'                
                    #Place caret at beginning
                    range = document.createRange()
                    range.selectNodeContents(@e[0])
                    range.collapse(true)
                    selection = window.getSelection()
                    selection.removeAllRanges()
                    selection.addRange(range);
            
        if @state.event is 'keypress'
            @e.find('.placeholder').remove()
            

        if @editor.options.titles is "inline" and @binding.title
            if @state.event is 'keypress' or @state.event is 'focus'
                if not @titleElement
                    @titleElement = $('<span class="editor-field-title">' + @binding.title + '</span>')
                    @editor.container.append @titleElement
                    @titleElement.css {
                        left: @e.position().left + @e.outerWidth() - @titleElement.width(),
                        top: @e.position().top + @e.height() - @titleElement.height()
                    }
                else                
                    top = @e.position().top + @e.height() - @titleElement.height()        
                    if @titleElement.position().top isnt top
                        @titleElement.css { top }
            else
                if @state.empty
                    @titleElement?.remove()
                    @titleElement = null
                
                

    update: (post) =>
        @e.find('.placeholder').remove()
        
        switch @binding.type
            when 'heading', 'plain-text'
                post[@fieldName] = @e.text()
            when 'text'
                post[@fieldName] = {
                    text: @e.html()
                    format: 'html'
                }
        
        
window.ForaEditor.Text = Text
