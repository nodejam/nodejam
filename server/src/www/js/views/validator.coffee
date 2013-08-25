class Validator

    constructor: (options) ->
        @validations = []
        @processed = 0
        @hasFocused = false

        @completionCb = options.onComplete            
        @page = options.page
        
        if options.form
            @parseForm options.form
            
        @emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/


    parseForm: (form) =>
        elems = $(form).find('[data-validation]')
        
        for e in elems
            e = $(e)
            validations = e.data('validation').split(',')
            for strValidation in validations
                @addValidation @createValidation strValidation.trim(), e
                                
        @validations
        
                
            
    createValidation: (strValidation, element) =>
        validation = {}

        if strValidation is 'required' or strValidation is 'email'
            validation.type = strValidation
            validation.element = element            
            
        else if /\(\)$/.test(strValidation)
            functionName = strValidation.replace /\(\)$/, ''
            validation.type = 'function'            
            validation.function = @page[functionName]
            validation.element = element

        validation.element.data 'validation-reference', validation
        
        id = element.attr('id')
        if id
            validation.label = $("label[for=#{id}]")
            validation.label.find('.error').remove()
            validation.label.data 'validation-reference', validation
            if not validation.label.data 'validation-original-text'
                validation.label.data 'validation-original-text', validation.label.text()                
        
        element.bindNew 'change', =>
            element.data('validation-reference').label.find('.error').remove()
        
        validation
                
                

    addValidation: (validation) =>
        @validations.push validation
        
    
    
    validate: =>
        for v in @validations
            do (v) =>
                if v.type is 'function'
                    v.function (result) =>
                        @processed++
                        if result isnt true
                            v.error = result
                        @onValidate v
                else
                    @processed++            
                    if v.type is 'required'
                        if not v.element.val()
                            v.error = 'Required'
                    else if v.type is 'email'
                        if not @emailRegex.test v.element.val()
                            v.error = "Invalid email"
                    @onValidate v


    
    onValidate: (v) =>
        if v.error
            if v.label and not v.label.find('.error').length
                v.label.append "<span class=\"error\"> #{v.error}</span>"
        if @processed is @validations.length
            errors = (_v for _v in @validations when _v.error)
            if errors.length
                #focus on the first error.            
                errors[0].element.focus()
            @completionCb errors.length == 0, errors
            
        
window.Fora.Views.Validator = Validator
