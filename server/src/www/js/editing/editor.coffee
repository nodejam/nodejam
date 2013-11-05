class Editor
    
    constructor: (@typeDefinition) ->
        @editables = $('[data-field-type]')
                        

        
    editPage: =>
        @editables.highlight()        
    
        for e in @editables
            do (e) =>
                e =  $(e)
                switch e.data('field-type')                
                    when 'image'
                        @setupImage e
                        
                    when 'title'
                        @setupTextElement e
                                            
                    when 'text'            
                        @setupTextElement e
                                    
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



    setupImage: (e) =>
        if not e.find('img').length            
            e.html '
                <p class="editor-option add-picture">
                    <i class="icon-picture"></i> <a href="#">Add a picture</a>
                </p>'
            e.find('p a').clickHandler => @addImage e
                
                
                
    addImage: (e) =>
        uid = Fora.uniqueId()
        $('body').append "
            <form style=\"display:none;width:0;height:0\" id=\"upload-form-#{uid}\" enctype=\"multipart/form-data\" action=\"/api/images\" target=\"upload-frame-#{uid}\" method=\"POST\" style=\"display:none\">
                <input name=\"file\" type=\"file\" />
                <iframe id=\"upload-frame-#{uid}\" name=\"upload-frame-#{uid}\"></iframe>
            </form>"

        form = $("#upload-form-#{uid}")
        form.find("input").change => 
            if form.find("input").val()
               form.submit()
       
        frame = $("#upload-frame-#{uid}")
        frame.load =>
            image = JSON.parse($(frame.contents()[0]).text()).image
            smallImage = JSON.parse($(frame.contents()[0]).text()).small
            e.html "<img src=\"#{image}\" data-small-image=\"#{smallImage}\" alt=\"\" />"
            form.remove()
            
        form.find("input").click()
        
            
    
    setupTextElement: (e) =>    
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
        
        
        
    update: (record = {}) =>
        for e in @editables
            e =  $(e)
            switch e.data('field-type')                
                when 'title'
                    record[e.data('field-name')] = e.text()
                when 'text'
                    field = e.data('field-name')
                    record[field + '_text'] = e.html()
                    record[field + '_format'] = 'html'
        record
                    

CKEDITOR.disableAutoInline = true

window.Fora.Editing.Editor = Editor
