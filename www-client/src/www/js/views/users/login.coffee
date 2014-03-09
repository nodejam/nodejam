class Login extends window.Fora.Views.BaseView

    constructor: (@token) ->

        $(document).ready =>
            @setupEditor()
            $('button.create').click @createUser
                            
                
        
    setupEditor: =>
    
        typeDefinition = {
            schema: {
                properties: {
                    username: { type: 'string', maxLength: 20 }                        
                    name: { type: 'string', maxLength: 20, pattern: '' }                        
                    about: { type: 'string', maxLength: 20, pattern: '' }
                    picture: { type: 'image' }                        
                }
            }
        }
        
        @editor = new ForaEditor typeDefinition, { titles: "inline" }, "#create-user-form"

        #username
        usernameRegex = new RegExp '^[A-Za-z][A-Za-z0-9_]*$'
        usernameValidate = (control, [e]) ->
            if e.keyCode is 32
                control.showMessage "underscores are ok, but not spaces", "error"
                return
                
            #alphabets and numbers only
            username = control.value()
            if username and not usernameRegex.test username
                control.showMessage "alphabets, numbers or underscores", "error"
            else
                control.clearMessage()
                
            #is the username available. 404 = available
            userExists = (cb) =>                        
                app.api "users/#{username}", {
                    success: (data) -> 
                        control.showMessage("unavailable", "error")
                }

            if @userCheck
                clearTimeout @userCheck
                       
            @userCheck = setTimeout userExists, 1000
        
        usernameBinding = { 
            element: '.username', 
            title: 'nickname', 
            placeholder: 'type a nickname', 
            events: { 
                keyup: usernameValidate,
                blur: usernameValidate
            },            
        }
        
        if $('.username').data('suggestion')
            usernameBinding.placeholder += ", say #{$('.username').data('suggestion')}"
        
        usernameControl = @editor.addBinding 'username', usernameBinding 
        
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
        
        #profile picture
        imageControl = @editor.addBinding 'picture', {
            type: 'image',
            element: '.picture',
            uploadUrl: app.apiUrl('images?src_size=192x192&small_size=96x96'),
            events: {
                change: (control, data) ->
                    $('.picture').data 'src', data.src
                    $('.picture').data 'small', data.small
            }            
        }
        
        
        
    createUser: =>
        app.api "users", {
            data: @editor.value(),
            type: 'post',
            success: (data) -> alert(data)
        }
             


    onSubmit: (e) =>
        
    
            
        
            
window.Fora.Views.Users.Login = Login
