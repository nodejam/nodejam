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

