class Login extends window.Fora.Views.BaseView

    constructor: ->
        $(document).ready =>
            @attachEvents

            typeDefinition = {
                schema: {
                    properties: {
                        username: { type: 'string', maxLength: 20, pattern: '^[A-Za-z][A-Za-z0-9]*$' }                        
                        name: { type: 'string', maxLength: 20, pattern: '' }                        
                        about: { type: 'string', maxLength: 20, pattern: '' }                        
                    }
                }
            }
            
            bindings = {
                username: { element: '.username', title: 'nickname', placeholder: 'type a nickname' } 
                name: { element: '.fullname', title: 'name', placeholder: 'your name' }
                about: { element: '.about', title: 'tag line', placeholder: 'and a fancy tag line...' } 
            }

            @editor = new ForaEditor typeDefinition, bindings, { titles: "inline" }, "#create-user-form"
        
    
    attachEvents: =>
        



    onSubmit: (e) =>
        
    
            
    validate: (cb) =>
        
        

    userExists: (cb) =>
        $.get "/api/users/#{$('#username').val()}", (data) =>
            cb if data then "Not available" else true
        
            
window.Fora.Views.Users.Login = Login
