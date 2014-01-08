class Image 

    constructor: (@e, @editor) ->

    setup: =>
        if @e.prop("tagName").toLowerCase() is "img" #We'll keep lower as standard. nodeNames are uppercase only if node is known to browser.
            divId = @editor.getRandomElementId()
            @e.replaceWith "
                <div class=\"editor-container\" id=\"#{divId}\">
                    #{e[0].outerHTML}
                    <p class=\"editor-inline-bar\"><a class=\"remove\" href=\"#\">Remove</a></p>
                </div>"

            container = $("##{divId}")
            container.find("a.remove").clickHandler =>
                fieldName = container.find("img").data("field-name")
                container.replaceWith "<div id=\"#{divId}\" class=\"image\" data-field-type=\"image\" data-field-name=\"#{fieldName}\"></div>"
                @setup $("##{divId}")
                
        else
            @e.html '
                <p class="editor-option-row icon-text">
                    <i class="fa fa-picture-o"></i> <a href="#">Add a picture</a>
                </p>'
            @e.find('p a').clickHandler @addImage
                
                
                
    addImage: =>
        formId = @editor.getRandomElementId()
        frameId = @editor.getRandomElementId()
        
        $('body').append "
            <form style=\"display:none;width:0;height:0\" id=\"#{formId}\" enctype=\"multipart/form-data\" action=\"/api/images\" target=\"#{frameId}\" method=\"POST\" style=\"display:none\">
                <input name=\"file\" type=\"file\" />
                <iframe id=\"#{frameId}\" name=\"#{frameId}\"></iframe>
            </form>"

        form = $("##{formId}")
        form.find("input").change => 
            if form.find("input").val()
               form.submit()
       
        frame = $("##{frameId}")
        frame.load =>
            imageId = @editor.getRandomElementId()
            image = JSON.parse($(frame.contents()[0]).text()).image
            smallImage = JSON.parse($(frame.contents()[0]).text()).small
            fieldName = @e.data("field-name")
            @e.replaceWith "<img src=\"#{image}\" id=\"#{imageId}\" data-field-type=\"image\" data-field-name=\"#{fieldName}\" data-small-image=\"#{smallImage}\" class=\"image\" alt=\"\" />"
            @setup $("##{imageId}")
            form.remove()            
            
        form.find("input").click()    



    update: (post) =>
        if @e.attr('src')
            post[@e.data('field-name')] = {
                src: @e.attr('src'),
                alt: @e.attr('alt'),
                small: @e.data('small-image')
            }

window.Fora.Editing.Image = Image
