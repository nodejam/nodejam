window.DEBUG_CLIENT_BUILD = ""

$(document).ready ->
    setInterval checkVersion, 1000

checkVersion = ->
    $.ajax '/system/build.txt', {
        success: (data) ->
            if window.DEBUG_CLIENT_BUILD and data isnt window.DEBUG_CLIENT_BUILD
                window.location.reload()                
            window.DEBUG_CLIENT_BUILD = data
    }
