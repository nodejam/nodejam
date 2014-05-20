
class CssStyles

    $(document).ready ->
        evaluateStyles()
        $(window).resize evaluateStyles


    evaluateStyles = ->
        handleCover()


    handleCover = ->    
        cover = $('.cover')
        if cover.hasClass 'full-cover'
            cover.height $(window).innerHeight()

module.exports = CssEval
