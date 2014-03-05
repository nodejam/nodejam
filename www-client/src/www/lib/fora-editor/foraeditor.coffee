class ForaEditor
    
    constructor: (@typeDef, @bindings, @options, @container) ->
        @container = $(@container)
        @container.addClass 'editable'

        @editedElements = []
        
        for fieldName, binding of @bindings
            elem = @container.find binding.element
            control = @bind elem, fieldName, @typeDef.schema.properties[fieldName], binding
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



    bind: (elem, fieldName, fieldProperties, binding) =>
        type = binding.type ? "plain-text"
        
        control = switch type
            when 'heading', 'text', 'plain-text'
                ForaEditor.Text 
            when 'selectable'
                ForaEditor.Selectable
            when 'cover'
                ForaEditor.Cover
                
        new control elem, fieldName, fieldProperties, binding, this
    


window.ForaEditor = ForaEditor
