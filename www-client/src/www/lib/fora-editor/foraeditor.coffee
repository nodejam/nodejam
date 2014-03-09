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
        "e#{@uniqueId()}"



    bind: (elem, fieldName, fieldProperties, binding) =>
        binding.type ?= "text"
        
        control = switch binding.type
            when 'text'
                ForaEditor.Text 
            when 'image'
                ForaEditor.Image
            when 'selectable'
                ForaEditor.Selectable
                
        new control elem, fieldName, fieldProperties, binding, this
    


    value: (obj = {}) =>
        for elem in @editedElements
            control = elem.data('control')
            value = control.value()

            if @typeDef.schema.required.indexOf(control.fieldName) > -1 and not value
                control.showMessage "required", "error"
                return

            obj[control.fieldName] = control.value()

        return obj
        
        
        
    uniqueId: (length = 16) =>
      id = ""
      id += Math.random().toString(36).substr(2) while id.length < length
      id.substr 0, length     
         
         
                     
window.ForaEditor = ForaEditor


