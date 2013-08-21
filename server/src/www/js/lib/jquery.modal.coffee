(($) ->

    $.fn.extend leanModal: (options) ->

        close_modal = ->
            $("#lean_overlay").fadeOut 200
            $(@).css display: "none"

        defaults =
            top: 100
            overlay: 0.9
            closeButton: null

        overlay = $("<div id='lean_overlay'></div>")

        $("body").append overlay

        options = $.extend(defaults, options)
        
        @each ->
            o = options

            $("#lean_overlay").click ->
                close_modal @

            $(o.closeButton).click ->
                close_modal @

            modal_height = $(@).outerHeight()
            modal_width = $(@).outerWidth()
            $("#lean_overlay").css
                display: "block"
                opacity: 0

            $("#lean_overlay").fadeTo 200, o.overlay
            $(@).css
                display: "block"
                position: "fixed"
                opacity: 0
                "z-index": 11000
                left: 50 + "%"
                "margin-left": -(modal_width / 2) + "px"
                top: o.top + "px"

            $(@).fadeTo 200, 1


) jQuery
