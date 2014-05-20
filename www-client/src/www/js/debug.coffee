
class DebugUtil

    DEBUG_CLIENT_BUILD: ""


    constructor: ->
        $(document).ready ->
            setInterval checkVersion, 1000


    checkVersion: ->
        if ["1", "true", "yes"].indexOf(Fora.Utils.getUrlParams "reload") > -1
            $.get '/system/build.txt', (data) -> 
                if @DEBUG_CLIENT_BUILD and data isnt @DEBUG_CLIENT_BUILD
                    #First make an ajax request to check if server is ready. (Some builds cause server restarts)
                    $.ajax '/healthcheck', {
                        type: 'get',
                        success: (data) ->
                            #All OK. Reload()
                            @location.reload()
                        error: ->
                            @DEBUG_CLIENT_BUILD = "invalid"
                    }
                @DEBUG_CLIENT_BUILD = data

module.exports = DebugUtil
