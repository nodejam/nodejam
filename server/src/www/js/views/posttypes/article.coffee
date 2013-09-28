class Article

    constructor: ->
        $(document).ready @attachEvents
        
        
        
    attachEvents: =>
        $('button.edit').click @onEdit



    onEdit: =>
        $('.edit-options').hide()
        
        $('.page-wrap').prepend '
            <div  class="nav buttons">
                <ul>
                    <li><button>Delete</button></li>
                    <li><button>Discard</button></li>
                    <li><button class="positive">Publish</button></li>
                </ul>
            </div>'
        
        editor = new Fora.Editing.Editor()
        editor.editRegion()
    

window.Fora.Views.PostTypes.Article = Article
