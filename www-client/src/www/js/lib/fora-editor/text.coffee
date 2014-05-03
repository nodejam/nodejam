class Text 

    constructor: (@element, @fieldName, @fieldProperties, @binding, @editor) ->
        @setup()



    setup: =>
        @element.attr 'contenteditable', true
        
        if not @binding.multiline
            @element.attr 'spellcheck', false
        
        @element.mousedown @onClick
        @element.bind 'touchstart', @onClick
        @element.focus @onFocus             
        @element.blur @onBlur        
        @element.keydown @onKeydown
        @element.keyup @onKeyup
        @element.keypress @onKeypress

        @state = { 
            event: "blur",
            empty: @isEmpty()
        }

        @evalControlState()
            


    focus: =>
        @onFocus()
        
    

    onClick: =>
        @focusReason = 'click'
        
        
    
    onFocus: =>
        #if this is already the active element, pretend nothing happened.
        #This happens when the user clicks the same element with a mouse.
        if this isnt @editor.activeControl
            @editor.activeControl = this
            @state.event = "focus"
            @state.empty = @isEmpty()
            @evalControlState()            
            @binding.events?.focus? this, arguments
            @focusReason = null



    onKeydown: (e) =>
        @binding.events?.keydown? this, arguments



    onKeyup: (e) =>
        @binding.events?.keyup? this, arguments


    
    onKeypress: (e) =>        
        if not @binding.multiline
            if e.keyCode is 13
                return e.preventDefault()
    
        @state.event = "keypress"        
        @state.empty = false
        @evalControlState()
        @binding.events?.keypress? this, arguments
            
        
    
    onBlur: =>
        @state.event = "blur"
        @state.empty = @isEmpty()
        @evalControlState()
        @binding.events?.blur? this, arguments



    value: =>
        val = @element.clone().children('.placeholder').remove().end().text().trim()
        val.replace /&nbsp;/, ''
        


    isEmpty: =>
        if @value() then false else true



    evalControlState: =>
    
        if @state.event is 'blur' 
            if @state.empty
                @element.html "<span class=\"placeholder\"><span class=\"caret\">&nbsp;</span><span class=\"placeholder-text\">#{@binding.placeholder}</span>"
                
        else if @state.event is 'focus'
        
            if @state.empty
                placeholder = @element.find('.placeholder')
                if placeholder.length
                    placeholder.addClass 'dim'         
                    @setCaretPosition 'start'       
            else
                #If focus reason is click or touch, then we shouldn't select the text.
                if @focusReason isnt 'click'
                    @selectText()

        else if @state.event is 'keypress'
            @element.find('.placeholder').remove()
            @clearMessage()
            

        if @editor.options.titles is "inline" and @binding.title
        
            if not (@state.event is 'keypress' or @state.event is 'focus')
                if @state.empty
                    @titleElement?.remove()
                    @titleElement = null
                    
            if not @state.empty or (@state.event is 'keypress' or @state.event is 'focus')
                if not @titleElement
                    @titleElement = $("<span class=\"editor-field-title\">#{@binding.title}</span>")
                    @editor.container.append @titleElement

                    #Allow time for rendering. 50ms seems alright.
                    setTimeout (=> 
                        @titleElement.css {
                            left: @element.position().left + @element.outerWidth() - @titleElement.outerWidth() - 6,
                            top: @element.position().top + @element.outerHeight() - @titleElement.outerHeight()
                        }), 50

                else                
                    #Allow time for rendering. 50ms seems alright.
                    setTimeout (=> 
                        top = @element.position().top + @element.outerHeight() - @titleElement.outerHeight()        
                        if @titleElement.position().top isnt top
                            @titleElement.css { top }
                        ), 50

                

    showMessage: (msg, type) =>
        @clearMessage()
        @element.addClass type
        @messageElement = $("<span class=\"editor-field-message #{type}\">#{msg}</span>")
        @editor.container.append @messageElement
        @messageElement.css {
            left: @element.position().left + @element.outerWidth() - @messageElement.width(),
            top: @element.position().top + @element.height() - @messageElement.height()
        }
        


    clearMessage: =>
        for type in ['error', 'warn', 'success']
            @element.removeClass type 
        @messageElement?.remove()
        @messageElement = null

        

    setCaretPosition: (position) =>
       setTimeout (=>
            range = document.createRange()
            range.selectNodeContents(@element[0])
            range.collapse position is 'start'
            selection = window.getSelection()
            selection.removeAllRanges()
            selection.addRange(range)), 50

    
    
    selectText: =>
       setTimeout (=>
            if (window.getSelection and document.createRange)
                range = document.createRange()
                range.selectNodeContents(@element[0])
                sel = window.getSelection()
                sel.removeAllRanges()
                sel.addRange(range)
            else if (document.body.createTextRange)
                range = document.body.createTextRange()
                range.moveToElementText(@element[0])
                range.select()), 50
                
                

window.ForaEditor.Text = Text
