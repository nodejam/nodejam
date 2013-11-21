class Create extends window.Fora.Views.BaseView

    constructor: ->        
        $(document).ready =>
            editor = new Fora.Editing.Editor($ '.content-area')
            
window.Fora.Views.Forums.Create = Create
