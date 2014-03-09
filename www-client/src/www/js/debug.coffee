window.DEBUG_CLIENT_BUILD = ""

$(document).ready ->
    setInterval checkVersion, 1000

checkVersion = ->
    $.get '/system/build.txt', (data) -> 
        if window.DEBUG_CLIENT_BUILD and data isnt window.DEBUG_CLIENT_BUILD
            #First make an ajax request to check if server is ready. (Some builds cause server restarts)
            app.api 'healthcheck', {
                success: (data) ->
                    #All OK. Reload()
                    window.location.reload()
                error: ->
                    window.DEBUG_CLIENT_BUILD = "invalid"
            }
        window.DEBUG_CLIENT_BUILD = data

