class Editor

    constructor: (@options) ->
        @editables = []
        
    
    editable: (selector, options) =>
        editable = new Editable selector, options, this
        @editables.push editable
        return editable
        
        
    activateEditable: (editable) =>
        if @activeEditable isnt editable
            @activeEditable?.deactivate()
        @activeEditable = editable
        
    #Utility functions
    uniqueId: (length = 16) ->
      id = ""
      id += Math.random().toString(36).substr(2) while id.length < length
      id.substr 0, length

        
class Editable

    constructor: (@selector, @options, @editor) ->
        

                    
    attachHandlers: =>
        self = this

        $(document).on 'mousedown', @selector, (e) => 
            @clickArgs = e
            @closeOptionsForm()
            
        $(document).on 'focus', @selector, @activate

        $(document).on 'click', "#{@selector} a", (e) ->
            self.showLinkOptions @
        
        
        
    handleAction: (what) =>
        switch what
            when 'bold'
                document.execCommand 'bold', false, null
            when 'italic'
                document.execCommand 'italic', false, null
            when 'h2'
                document.execCommand 'formatBlock', false, "<h2>"
            when 'image'          
                uniqueId = "bangjs-image-insert-#{@editor.uniqueId()}"
                @pasteHtmlAtCaret "<div id=\"#{uniqueId}\" class=\"bangjs-image-insert\"></div>"
                @showUploadBox "##{uniqueId}", @options.imageOptions
            when 'list'
                @pasteHtmlAtCaret "<ul><li>Item 1</li></ul>"            
            when 'link'
                markerUrl = @editor.uniqueId()
                document.execCommand 'createLink', false, markerUrl
                link = $("a[href=#{markerUrl}]")
                link.attr "href", ""
                @showLinkOptions link[0]
            when 'quote'
                @wrapHtml "“", "”"
            when 'indent'
                document.execCommand 'formatBlock', false, 'blockquote'
                #bq = document.createElement("blockquote")
                #@surroundSelectedText(bq)
            when 'unformat'
                e = @getNodeAtCaret()
                $(e).contents().parent('blockquote,h1,h2,h3').contents().unwrap()
    
    
    makeEditable: =>
        switch @options.mode
            when 'text'
                $(@selector).attr 'contenteditable', 'true'
            when 'html'
                @toolbar = new BangJS.Toolbar({ items: "h2,bold,italic,image,link,list,quote,indent,unformat" }, this)
                $(@selector).attr 'contenteditable', 'true'
                @fixHtml 'load'
                @makeImagesEditable()                
            when 'image'
                @makeImagesEditable()
            
        $(@selector).addClass 'bangjs-editable'
        @attachHandlers()
            

            
    activate: (event) =>
        @editor.activateEditable(this)                                
        
        if not @isActive                       
            @isActive = true

            if @toolbar
                if @clickArgs
                    if @options.position 
                        @toolbar.setPosition @options.position event 
                    else 
                        @toolbar.setPosition { left: @clickArgs.pageX - $(window).scrollLeft() + 20, top: @clickArgs.pageY - $(window).scrollTop() - 80 }
                else
                    @toolbar.setPosition { left: $(@selector).position().left + 20, top: $(@selector).position().top - 80 }

                @toolbar.show()                   
        @clickArgs = null
        true


    deactivate: =>
        @isActive = false
        @toolbar?.hide()    
    
            

    makeImagesEditable: =>
        #If there is an image inside selector, we add image editing tags to it.
        #If there is no image, we add an upload option.
        img = $(@selector).find('img')
        if img.length
            img.wrap('<div class="image-container"></div>')                        
            @addImageOptions @options.imageOptions, $(@selector).find '.image-container'
        else
            @options.imageOptions.onEmpty?()
                    
                    
                    
    showUploadBox: (selector, options) =>
        options.name ?= "bangjs-image-editable-" + @editor.uniqueId()
                
        element = $(selector)

        options.title ?= 'Upload a picture'

        element.html "
        <div class=\"#{options.name} image-upload-box\" contenteditable=\"false\">
            <form name=\"form\" method=\"POST\" target=\"#{options.name}-frame\" enctype=\"multipart/form-data\" >
                <p>
                    #{options.title}: <br />
                    <input type=\"file\" class=\"file-input\" name=\"file\" />
                </p>
                <p>
                    <i class=\"icon-remove\"></i>
                </p>
                <iframe id=\"#{options.name}-frame\" name=\"#{options.name}-frame\" src=\"\" style=\"display:none;height:0;width:0\"></iframe>
            </form>
        </div>"
        
        element.find('i.icon-remove').click =>
            if options.onEmpty
                options.onEmpty()
            else
                element.remove()
        
        $(document).bindNew 'change', ".#{options.name} .file-input", => @onImageSelect(options)
                    
                
    
    onImageSelect: (options) =>
        form = $(".#{options.name} form")
        form.attr 'action', options.uploadUrl
        frame = $("##{options.name}-frame")
        frame.bindNew 'load',=>
            image = JSON.parse($(frame[0].contentWindow.document).text()).image
            thumbnail = if options.createThumbnail then JSON.parse($(frame[0].contentWindow.document).text()).thumbnail
            @setImage options, image, thumbnail
        form.submit()            

   
        
    setImage: (options, imageUrl, thumbnailUrl) =>
        imageBox = $('<div class="image-container"></div>')
        imageBox.html "<img src=\"#{imageUrl}\" data-filter=\"none\" data-src=\"#{imageUrl}\" data-thumbnail-src=\"#{thumbnailUrl}\" class=\"picture\" />"
        $(".#{options.name}").replaceWith imageBox
        @addImageOptions options, imageBox
            
        
    
    addImageOptions: (options, imageBox) =>
        if @options.mode is 'image'    
            imageBox.append "
                <div class=\"bg bangjs-option\"></div>
                <div class=\"picture-options bangjs-option\">
                    <p class=\"buttons\">
                        <a href=\"#\" class=\"add-title\">Add caption</a><span class=\"gray\"> | </span><a href=\"#\" class=\"remove\">Remove</a>
                    </p>
                </div>"
            imageBox.find('a.remove').click =>
                if options.onEmpty
                    options.onEmpty()
                else
                    imageBox.remove()
                false
            
            

    showLinkOptions: (link) =>
        link = $(link)
        @closeOptionsForm()
        options = $("<div class=\"bangjs-options-form\" style=\"display:none\">
                        <p>
                            <input class=\"url\" placeholder=\"http://www.example.com\" type=\"text\" style=\"width:300px;\" /> or <a class=\"clear\" href=\"#\">clear</a>.
                        </p>
                    </div>")

        $('body').append options
        options.css { left: "#{link.position().left}px", top: "#{link.position().top-40}px" }
        options.show()
        
        
        if link.attr('href')
            $('.bangjs-options-form input.url').val link.attr('href')

        $('.bangjs-options-form input.url').focus()

        options[0].onClose = =>
            if $('.bangjs-options-form input.url').val()
                link.attr('href', $('.bangjs-options-form input.url').val())
            else
                link.contents().unwrap()                    
            
        $(document).off 'click', '.bangjs-options-form a.clear'
        $(document).on 'click', '.bangjs-options-form a.clear', =>
            link.contents().unwrap()
            @closeOptionsForm false
            false

        $(document).off 'keypress', '.bangjs-options-form input.url'
        $(document).on 'keypress', '.bangjs-options-form input.url', (e) =>
            if e.which == 13
                if $('.bangjs-options-form input.url').val()
                    link.attr('href', $('.bangjs-options-form input.url').val())
                else
                    link.contents().unwrap()                    
                @closeOptionsForm false
            
        false
        
    
    
    closeOptionsForm: (fireClose = true) =>
        form = $('.bangjs-options-form')
        if form.length
            if fireClose
                form[0].onClose?()
            form.remove()
        


    pasteHtmlAtCaret: (html) =>
        if (window.getSelection)
            #IE9 and non-IE    
            sel = window.getSelection()
            if (sel.getRangeAt && sel.rangeCount)
                range = sel.getRangeAt(0)
                range.deleteContents()

                #Range.createContextualFragment() would be useful here but is
                # non-standard and not supported in all browsers (IE9, for one)
                el = document.createElement("div")
                el.innerHTML = html
                frag = document.createDocumentFragment()
                while (node = el.firstChild)
                    lastNode = frag.appendChild(node)

                range.insertNode(frag)

                #Preserve the selection
                if (lastNode)
                    range = range.cloneRange()
                    range.setStartAfter(lastNode)
                    range.collapse(true)
                    sel.removeAllRanges()
                    sel.addRange(range)

        else if (document.selection && document.selection.type != "Control")
            #IE < 9
            document.selection.createRange().pasteHTML(html);


    surroundSelectedText: (element) =>
        if (window.getSelection)
        #IE9 and non-IE
            sel = window.getSelection()
            if (sel.getRangeAt && sel.rangeCount)
                range = sel.getRangeAt(0)
                element.appendChild document.createTextNode(range.toString())
                range.deleteContents()
                range.insertNode(element)

                #Preserve the selection
                range = range.cloneRange()
                range.setStartAfter(element)
                range.collapse(true)
                sel.removeAllRanges()
                sel.addRange(range)
            else if (document.selection && document.selection.type != "Control")
                #IE < 9
                selRange = document.selection.createRange()
                element.appendChild( document.createTextNode(selRange.text) )
                selRange.pasteHTML(element.outerHTML)


    wrapHtml: (leftInsert, rightInsert) =>
        if (window.getSelection)
            sel = window.getSelection()

            if (sel.rangeCount)
                range = sel.getRangeAt(0)
                selectedText = range.toString()
                range.deleteContents()
                range.insertNode document.createTextNode(leftInsert + selectedText + rightInsert)

        else if (document.selection && document.selection.createRange)
            range = document.selection.createRange()
            selectedText = document.selection.createRange().text + ""
            range.text = leftInsert + selectedText + rightInsert



    getNodeAtCaret: =>
        node = document.getSelection().anchorNode
        if (node.nodeType == 3) then node.parentNode else node
        
        

    fixHtml: (event) =>
        if @options.mode is 'html'
            if event is 'save'
                $('.bangjs-option').remove()
                $('h1,h2,h3').each ->
                    $('<br />').insertAfter $(@)
                $('blockquote').each ->
                    $('<br /><br />').insertAfter $(@)
                    
            #Replace p tags with content<br /><br /> tags; and div tags with content<br /> tags;
            $('.post-content p').each ->
                container = $('<div></div>')
                contents = $(@).contents()
                container.append contents
                container.append '<br />'
                #if contents.last()[0]?.tagName?.toLowerCase() is 'br'
                #    container.append '<br />'
                #else
                #    container.append '<br /><br />'
                $(@).replaceWith container

            $('.post-content div').each ->
                contents = $(@).contents()
                last = contents.last()
                $(@).replaceWith contents
                $('<br />').insertAfter last



    getValue: (format) =>
        switch format
            when 'markdown'
                @fixHtml 'save'
                new reMarked().render $(@selector)[0]
            when 'text'
                return $(@selector).text()
                                        
window.BangJS = { Editor }
