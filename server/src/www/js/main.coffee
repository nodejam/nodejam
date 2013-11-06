window.Fora = {
    Views: {
        Home: {},
        Collections: {},
        Users: {},
        Records: {},
        RecordTypes: {},
    },
    Editing: {}
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
        "/~#{user.username}"

        
        
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

`
window.Fora.getUrlParams = function (name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
`

#Avoid caching in jQuery
$.ajaxSetup({
    cache: false
})



#Some extensions to jQuery
$.fn.bindNew = (eventName, p1, p2) ->
    fn = p2 ? p1
    if not p2?
        $(this).off eventName
        $(this).on eventName, fn    
    else
        $(this).off eventName, p1
        $(this).on eventName, p2, fn
    this


    
$.fn.clickHandler = (p1, p2) ->
    fn = p2 ? p1
    _fn = ->
        fn.apply this, arguments
        false
    if not p2?
        $(this).off 'click touch'
        $(this).on 'click touch', _fn
    else
        $(this).off 'click touch', p1
        $(this).on 'click touch', p1, _fn
    this
    


$.fn.highlight = ->
    elem = this
    $(elem).removeClass 'unhighlight'
    $(elem).addClass 'highlight'
    unhighlight = ->
        $(elem).removeClass 'highlight';
        (elem).addClass 'unhighlight'
    setTimeout unhighlight, 1000
    this

        
