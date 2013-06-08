class Toolbar

    constructor: (@options, @editable) ->
        @element = $('<div class="bangjs-editor-toolbar" style="display:none">
                        <div class="handle">
                            <i class="icon-move"></i>
                        </div>
                        <ul class="buttons"></ul>
                        <div class="options-form" style="display:none"></div>
                    </div>')
        $('body').append @element
        @buttons = @element.find('.buttons')
        @element.drags()   

        items = @options.items.split ','
        @element.css 'width', "#{20 + (items.length*35)}px"

        for item in items
            switch item
                when 'h1'
                    @buttons.append '<li class="ce-icon-h1"><span href="#">H</span><li>'
                    @buttons.find('.ce-icon-h1').click => @handleClick => @editable.handleAction('h1')
                when 'h2'
                    @buttons.append '<li class="ce-icon-h2 hint hint--top" data-hint="Heading"><spanv href="#">H</span></li>'
                    @buttons.find('.ce-icon-h2').click => @handleClick => @editable.handleAction('h2')
                when 'bold'
                    @buttons.append '<li class="ce-icon-bold hint hint--top" data-hint="Bold"><span href="#">b</span></li>'
                    @buttons.find('.ce-icon-bold').click => @handleClick => @editable.handleAction('bold')
                when 'italic'
                    @buttons.append '<li class="ce-icon-italic hint hint--top" data-hint="Italic"><span href="#">i</span></li>'
                    @buttons.find('.ce-icon-italic').click => @handleClick => @editable.handleAction('italic')
                when 'image'
                    @buttons.append '<li class="ce-icon-image hint hint--top" data-hint="Upload a picture"><i class="icon-picture"></i></li>'         
                    @buttons.find('.ce-icon-image').click => @handleClick => @editable.handleAction('image')
                when 'link'
                    @buttons.append '<li class="ce-icon-link hint hint--top" data-hint="Add a link"><i class="icon-link"></i></li>'         
                    @buttons.find('.ce-icon-link').click => @handleClick => @editable.handleAction('link')
                when 'list'
                    @buttons.append '<li class="ce-icon-list hint hint--top" data-hint="Create a list"><i class="icon-list"></i></li>'         
                    @buttons.find('.ce-icon-list').click => @handleClick => @editable.handleAction('list')
                when 'quote'
                    @buttons.append '<li class="ce-icon-quote hint hint--top" data-hint="Add quotes"><i class="icon-quote-left"></i></li>'         
                    @buttons.find('.ce-icon-quote').click => @handleClick => @editable.handleAction('quote')
                when 'indent'    
                    @buttons.append '<li class="ce-icon-indent hint hint--top" data-hint="Indent"><i class="icon-indent-right"></i></li>'         
                    @buttons.find('.ce-icon-indent').click => @handleClick => @editable.handleAction('indent')
                when 'unformat'    
                    @buttons.append '<li class="ce-icon-unformat hint hint--top" data-hint="Remove formatting"><i class="icon-remove-circle"></i></li>'         
                    @buttons.find('.ce-icon-unformat').click => @handleClick => @editable.handleAction('unformat')
    

    handleClick: (fn) =>
        fn()

    
    setPosition: (position) =>
        @element.css { top: "#{position.top}px", left: "#{position.left}px",  }

    
    hide: =>
        @element.hide()
        
        
    show: =>
        @element.show()
        

        
        
window.BangJS.Toolbar = Toolbar
