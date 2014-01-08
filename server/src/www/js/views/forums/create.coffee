class Create extends window.Fora.Views.BaseView

    constructor: ->        
        $(document).ready =>
            @editor = new Fora.Editing.Editor($ '.content-area')
            $('button.create').click @create
    
    create: =>
        forum = @editor.data()
        alert JSON.stringify forum
        $.post '/api/forums', forum, (data) =>
            alert JSON.stringify data
    
            
window.Fora.Views.Forums.Create = Create
