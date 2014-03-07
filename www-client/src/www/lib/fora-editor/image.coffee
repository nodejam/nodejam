class Image 

    constructor: (@element, @fieldName, @fieldProperties, @binding, @editor) ->
        @setup()



    setup: =>
        


    #uploads an image, takes a callback
    uploadImage = (fn) ->
        frameId = @editor.uniqueId()

        form = $ "
            <form style=\"display:none;width:0;height:0\" enctype=\"multipart/form-data\" action=\"/api/images\" target=\"#{frameId}\" method=\"POST\" style=\"display:none\">
                <input name=\"file\" type=\"file\" />
                <iframe name=\"#{frameId}\"></iframe>
            </form>"
        
        $('body').append formId
        
        form.find("input").change ->
            if form.find("input").val()
               form.submit()
       
        frame = form.find 'iframe'    
        frame.load ->
            src = JSON.parse($(frame.contents()[0]).text()).src
            small = JSON.parse($(frame.contents()[0]).text()).small
            fn src, small
            form.remove()            
            
        form.find("input").click()    



window.ForaEditor.Image = Image
