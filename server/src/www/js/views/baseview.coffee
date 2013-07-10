class BaseView

    constructor: (options = {}) ->         
        @instanceid = Lappd.uniqueId()     
        @href = window.location.href
        $(document).ready @attachEvents
        
        
    attachEvents: =>
        $('a.login-link').click =>
            $('a.login-link').hide()
            $('.signin-options').show()
            false
            
        $('li.logout').click =>
            app.logout()
            window.location.reload()
            false
            
window.Fora.Views.BaseView = BaseView
