class ForaEditor
    
    constructor: (@typeDef, @options, @container) ->
        @container = $(@container)
        @container.addClass 'editable'
        @editedElements = []


        
    addBinding: (fieldName, binding) =>
        elem = @container.find binding.element
        control = @bind elem, fieldName, @typeDef.schema.properties[fieldName], binding
        elem.data 'control', control
        @editedElements.push elem
        return control
        


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
        binding.type ?= "text"
        
        control = switch binding.type
            when 'text'
                ForaEditor.Text 
            when 'selectable'
                ForaEditor.Selectable
            when 'cover'
                ForaEditor.Cover
                
        new control elem, fieldName, fieldProperties, binding, this
    


    value: (obj = {}) =>
        for elem in @editedElements
            control = elem.data('control')
            obj[control.fieldName] = control.value()

        return obj
        
window.ForaEditor = ForaEditor
