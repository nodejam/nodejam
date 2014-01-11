#Generate a random identifier
window.Fora.Utils.uniqueId = (length = 16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length


#uploads an image, takes a callback
window.Fora.Utils.uploadImage (fn) ->
    frameId = "e_" + Fora.Utils.uniqueId(16)

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
        image = JSON.parse($(frame.contents()[0]).text()).image
        smallImage = JSON.parse($(frame.contents()[0]).text()).small
        fieldName = @e.data("field-name")
        fn image, smallImage, fieldName
        form.remove()            
        
    form.find("input").click()        
    
#get params by parsing the url. Decaf.    
`
window.Fora.Utils.getUrlParams = function (name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
`    
