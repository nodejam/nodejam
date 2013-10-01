class Article

    constructor: (@record) ->
        $(document).ready =>
            @attachEvents()
            mode = Fora.getUrlParams 'mode'
            if mode is 'edit'
                @onEdit()
        
        
        
    attachEvents: =>
        $('button.edit').click @onEdit



    onEdit: =>
        $('.edit-options').hide()
        
        $('.page-wrap').prepend '
            <div class="nav buttons">
                <ul>
                </ul>
            </div>'

        $('.page-wrap .nav.buttons ul').append '<li><button>Delete</button></li>'
        if @record.state is 'published'
            $('.page-wrap .nav.buttons ul').append '<li><button>Cancel</button></li>'
        $('.page-wrap .nav.buttons ul').append '<li><button class="positive">Publish Record</button></li>'
        
        editor = new Fora.Editing.Editor()
        editor.editPage if @record.title then '.content' else 'h1'
    

window.Fora.Views.RecordTypes.Article = Article
