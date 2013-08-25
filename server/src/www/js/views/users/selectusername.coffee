class SelectUsername extends window.Fora.Views.BaseView

    constructor: ->
        $(document).ready @attachEvents
        
        
    
    attachEvents: =>
        $('form.select-username').submit @onSubmit



    onSubmit: (e) =>
        e.preventDefault()
        @validate (result) =>
        false
        
    
            
    validate: (cb) =>
        validator = new Fora.Views.Validator {
            onComplete: cb,
            form: 'form.select-username',
            page: this
        }        
        validator.validate()
        
        

    userExists: (cb) =>
        $.get "/api/users/#{$('#username').val()}", (data) =>
            cb if data then "Not available" else true
        
            
window.Fora.Views.SelectUsername = SelectUsername
