class Editor
    
    constructor: (@typeDef, @bindings, @container, @options) ->
        @container = $(@container)
        @container.addClass 'editable'

        @editedElements = []
        
        for (fieldName, binding of @bindings)
            elem = @container.find binding.element
            elem.highlight()
            control = @getControl elem, @typeDef.schema.properties[fieldName], binding
            elem.data control
            @editedElements.push elem
            
    

    exit: =>
        


    data: (post = {}) =>
        for e in @editedElements
            e.data('control').update post
        @flatten post, [], {}
                    
                    
    
    flatten: (post, prefix, acc) =>
        for f, v of post
            if v and typeof v isnt "function"
                if typeof v is "object"
                    @flatten v, prefix.concat(f), acc
                else
                    acc[prefix.concat(f).join('_')] = v
        acc
        
        

    getRandomElementId: =>
        "e#{Fora.uniqueId()}"



    getControl: (elem, field, binding) =>
        if not 
        switch binding.type
            switch type
                when 'heading', 'text', 'plain-text'
                    Fora.Editing.Text
                when 'selectable'
                    Fora.Editing.Selectable
                when 'cover'
                    Fora.Editing.Cover
    


window.Fora.Editor = Editor
