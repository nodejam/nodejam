class Login extends window.Fora.Views.BaseView

    constructor: ->

        $(document).ready =>
            @setupEditor()
            $('button.create').click @onSubmit
                            
                
        
    setupEditor: =>
        typeDefinition = {
            schema: {
                properties: {
                    username: { type: 'string', maxLength: 20 }                        
                    name: { type: 'string', maxLength: 20, pattern: '' }                        
                    about: { type: 'string', maxLength: 20, pattern: '' }                        
                }
            }
        }
        
        @editor = new ForaEditor typeDefinition, { titles: "inline" }, "#create-user-form"

        #username
        usernameRegex = new RegExp '^[A-Za-z][A-Za-z0-9_]*$'
        usernameValidate = (control) ->
            #alphabets and numbers only
            username = control.value()
            if username and not usernameRegex.test username
                control.showMessage "alphabets, numbers or underscores", "error"
            else
                control.clearMessage()
                
            #is the username available
            userExists = (cb) =>                        
                $.get "/api/users/#{username}", (data) =>
                    cb if data then "not available"

            if @userCheck
                clearTimeout @userCheck

            @userCheck = setTimeout userExists, 1000
        
        usernameControl = @editor.addBinding 'username', { 
            element: '.username', 
            title: 'nickname', 
            placeholder: 'type a nickname', 
            events: { 
                keyup: usernameValidate,
                blur: usernameValidate
            } 
        } 
        
        #name
        nameControl = @editor.addBinding 'name', { 
            element: '.fullname', 
            title: 'name', 
            placeholder: 'your name'
        }
        
        #about
        aboutControl = @editor.addBinding 'about', { 
            element: '.about', 
            title: 'tag line', 
            placeholder: 'and a fancy tag line...' 
        } 
        
        



    onSubmit: (e) =>
        
    
            
        
            
window.Fora.Views.Users.Login = Login
