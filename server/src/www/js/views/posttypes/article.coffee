class Article

    constructor: ->
        $(document).ready @attachEvents
        
        
        
    attachEvents: =>
        $('button.edit').click =>
            editor = new Fora.Editors.InlineEditor()            
            editor.editPage()

window.Fora.Views.PostTypes.Article = Article
