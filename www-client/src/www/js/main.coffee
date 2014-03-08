window.Fora = {
    Views: {
        Home: {},
        Forums: {},
        Users: {},
        Posts: {},
    },
    Editing: {},
    Utils: {}
}

class App

    constructor: ->
        $(document).ready @init



    init: =>
        user = @getUser()
        if user
            $('.site-options .account').html "<a href=\"#{@getUserUrl()}\"><i class=\"fa fa-user\"></i>#{user.username}</a><a href=\"#\" class=\"right logout\"><i class=\"fa fa-sign-out\"></i></a>"
        else
            $('.site-options .account').html "<a class=\"login\" href=\"#\"><i class=\"fa fa-sign-in\"></i>Login</a>"

        @attachHandlers()


            
    attachHandlers: =>
        $(document).clickHandler '.logo', =>
            $('.logo').hide()        
            $('.site-options').show()

        $(document).bindNew 'click touch', '.site-options .transparent-overlay', =>
            $('.logo').show()        
            $('.site-options').hide()
                    
        $(document).clickHandler '.site-options .account .login', @login
        $(document).clickHandler '.site-options .account .logout', @logout
                    


    login: =>
        $('body').append '
            <div id="login-box">
                <ul>
                    <li><i class="fa fa-twitter"></i> <a class="twitter" href="/auth/twitter">Sign in with Twitter</a></li>
                </ul>
            </div>'
            
        $('#login-box').leanModal { onClose: => $('#login-box').remove() }
                


    logout: =>
        @clearCookies()
        $('.site-options .account').html "<a class=\"login\" href=\"#\"><i class=\"fa fa-sign-in\"></i>Login</a>"
        


    clearCookies: =>
        $.removeCookie('userId')
        $.removeCookie('username')
        $.removeCookie('fullName')



    getUser: =>
        if $.cookie('userId')
            {
                id: $.cookie('userId'),
                username: $.cookie('username'),
                name: $.cookie('fullName'),
            }
              
        
        
    getUserUrl: =>
        user = @getUser()
        "/~#{user.username}"

        
        
    isLoggedInUser: (user) => 
        user.username is @getUser().username
           
        
                
    loadScript: (src) =>
        $('head').append "<script src=\"#{src}\"></script>"        



    apiUrl: (url) =>
        "/api/v1/" + url
        
        
    
    api: (url, settings) =>
        url = "/api/v1/" + url
        $.ajax url, settings
    

window.app = new App



