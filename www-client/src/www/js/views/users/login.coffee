class Login extends window.Fora.Views.BaseView

    constructor: ->
        $(document).ready =>
            @attachEvents

            typeDefinition = {
                schema: {
                    properties: {
                        username: { type: 'string', title: 'Nickname', maxLength: 20, pattern: '' }                        
                        name: { type: 'string', 'Your name', maxLength: 20, pattern: '' }                        
                        about: { type: 'string', title: 'About', maxLength: 20, pattern: '' }                        
                    }
                }
            }
            
            bindings = {
                fields: {
                    username: { element: '.username', placeholder: 'Type in a nickname' } 
                    name: { element: '.name', placeholder: 'Your name' }
                    about: { element: '.about', placeholder: 'And a fancy tag line...' } 
                }
            }

            @editor = new Fora.Editor typeDefinition, bindings, "#create-user-form"
        
    
    attachEvents: =>
        



    onSubmit: (e) =>
        
    
            
    validate: (cb) =>
        
        

    userExists: (cb) =>
        $.get "/api/users/#{$('#username').val()}", (data) =>
            cb if data then "Not available" else true
        
            
window.Fora.Views.Users.Login = Login
