window.Fora = {
    Views: {
        Home: {},
        Collections: {},
        Users: {},
        Posts: {}
    }
}

class App

    constructor: ->
        $(document).ready @init


    init: =>
        $(document).clickHandler '.logo', =>
            $('.logo').show()        
            $('.site-options').show()

        $(document).bindNew 'click touch', '.site-options .transparent-overlay', =>
            $('.site-options').hide()
            
        

    getUser: =>
        {
            id: $.cookie('userid'),
            domain: $.cookie('domain'),
            username: $.cookie('username'),
            name: $.cookie('fullName'),
            passkey: $.cookie('passkey')
        }
        
        
    getUserUrl: =>
        user = @getUser()
        if user.domain is 'twitter'
            return "@#{user.username}"
        else
            return "#{user.domain}/#{user.username}"
        
        
    isLoggedInUser: (user) => 
        (user.domain is @getUser().domain) and (user.username is @getUser().username)
           

    login: (resp) =>
        options = {}
        $.cookie 'userid', resp.userid, options
        $.cookie 'domain', resp.domain, options
        $.cookie 'username', resp.username, options
        $.cookie 'fullName', resp.name, options
        $.cookie 'passkey', resp.passkey, options


    logout: =>
        @clearCookies()
        $('.account-options .signin').html '<i class="icon-twitter"></i><a href="/auth/twitter">Sign in</a>'
        

    clearCookies: =>
        $.removeCookie('userid')
        $.removeCookie('domain')
        $.removeCookie('username')
        $.removeCookie('fullName')
        $.removeCookie('passkey')    
        
        
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
    passkey = app.getUser().passkey
    if passkey
        params.passkey = passkey
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
    
