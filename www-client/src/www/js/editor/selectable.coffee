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



    update: (record) =>
        selected = @e.find('.selected')
        fieldName = @e.data('field-name')
        record[fieldName] = selected.data('field-value')

window.Fora.Editing.Selectable = Selectable
