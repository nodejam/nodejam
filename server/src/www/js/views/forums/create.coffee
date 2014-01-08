class Create extends window.Fora.Views.BaseView

    constructor: ->        
        $(document).ready =>
            editor = new Fora.Editing.Editor($ '.content-area')
            
    
    create: =>
        forum = editor.data()
        $.post '/api/forums', forum, =>
            alert 'created'
    
            
window.Fora.Views.Forums.Create = Create
