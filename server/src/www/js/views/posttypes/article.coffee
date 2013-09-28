class Article

    constructor: ->
        $(document).ready @attachEvents
        
        
        
    attachEvents: =>
        $('button.edit').click @onEdit



    onEdit: =>
        $('.content, h1').attr 'contenteditable', true
        
        $('.edit-options').hide()
        
        $('.page-wrap').prepend '
            <div  class="nav buttons">
                <ul>
                    <li><button>Delete</button></li>
                    <li><button>Discard</button></li>
                    <li><button class="positive">Publish</button></li>
                </ul>
            </div>'
        
        $('.content, h1').highlight()        
        @makeEditable '.content'        
        
    
    
    makeEditable: (element) =>
        editor = new Fora.Editing.Editor()
        editor.edit element
    
    

window.Fora.Views.PostTypes.Article = Article
