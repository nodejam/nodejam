class Selectable

    constructor: (@e, @editor) ->



    setup: =>
        e = @e
        e.children().click ->
            current = e.find('.selected')
            current.children('i.fa.fa-check').remove()
            current.removeClass 'selected'

            selected = $(this)
            selected.prepend '<i class="fa fa-check"></i>'
            selected.addClass 'selected'



    update: (post) =>

window.Fora.Editing.Selectable = Selectable
