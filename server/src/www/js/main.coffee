window.Fora = {
    Views: {
        Home: {},
        Forums: {},
        Users: {},
        Posts: {},
        Articles: {}
    }
}

class App

    constructor: ->
        $(document).ready @init



    init: =>
        user = @getUser()
        if user
            $('.site-options .account').html "<a href=\"#{@getUserUrl()}\"><i class=\"icon-user\"></i>#{user.username}</a><a href=\"#\" class=\"right logout\"><i class=\"icon-signout\"></i></a>"
        else
            $('.site-options .account').html "<a class=\"login\" href=\"#\"><i class=\"icon-signin\"></i>Login</a>"

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
                    <li><i class="icon-twitter"></i> <a class="twitter" href="/auth/twitter">Sign in with Twitter</a></li>
                </ul>
            </div>'
            
        $('#login-box').leanModal()
                


    onLogin: (resp) =>
        options = {}
        $.cookie 'userid', resp.userid, options
        $.cookie 'username', resp.username, options
        $.cookie 'fullName', resp.name, options
        $.cookie 'token', resp.token, options



    logout: =>
        @clearCookies()
        $('.site-options .account').html "<a class=\"login\" href=\"#\"><i class=\"icon-signin\"></i>Login</a>"
        


    clearCookies: =>
        $.removeCookie('userid')
        $.removeCookie('username')
        $.removeCookie('fullName')
        $.removeCookie('token')    



    getUser: =>
        if $.cookie('userid')
            {
                id: $.cookie('userid'),
                username: $.cookie('username'),
                name: $.cookie('fullName'),
                token: $.cookie('token')
            }
              
        
        
    getUserUrl: =>
        user = @getUser()
        "/users/#{user.username}"

        
        
    isLoggedInUser: (user) => 
        user.username is @getUser().username
           
        
        
        
    loadScript: (src) =>
        $('head').append "<script src=\"#{src}\"></script>"        

window.app = new App



#Utility functions
window.Fora.uniqueId = (length = 16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length


# Utility Functions
window.Fora.apiUrl = (url, params = {}, options = { api: 'v1'}) ->
    if /^\//.test(url)
        url = url.substring(1)
    token = app.getUser().token
    if token
        params.token = token
    if Object.keys(params).length > 0
        paramArray = []    
        for key, val of params
            paramArray.push "#{key}=#{encodeURIComponent(val)}"    
        query = paramArray.join '&'
        if /\?/.test(url)
            url += "&#{query}"
        else
            url += "?#{query}"
                
    "/api/#{options.api}/#{url}"


#Some extensions to jQuery
$.fn.bindNew = (eventName, p1, p2) ->
    if not p2?
        fn = p1
        $(this).off eventName
        $(this).on eventName, fn    
    else
        selector = p1
        fn = p2
        $(this).off eventName, selector
        $(this).on eventName, selector, fn

$.fn.clickHandler = (selector, fn) ->
    _fn = ->
        fn.apply this, arguments
        false
    $(this).off 'click touch', selector
    $(this).on 'click touch', selector, _fn
    
$.fn._hide = () ->
    $(this).removeClass 'visible'
    $(this).addClass 'hidden'
    
$.fn._show = () ->
    $(this).removeClass 'hidden'
    $(this).addClass 'visible'
    
