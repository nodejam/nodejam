class Record

    constructor: (@record, @typeDefinition) ->        
        $(document).ready () =>
            @editable = app.getUser()?.id is @record.createdBy.id
            if @editable
                $('.sidebar-options').html '
                    <p class="edit-options">
                        <button class="edit positive">Edit Post</button>
                        <button><i class="settings icon-cog"></i>Settings</button>
                    </p>'
            
            @attachEvents()
            
            if @editable
                mode = Fora.getUrlParams 'mode'
                if mode is 'edit'
                    @onEdit()                
        
        
        
    attachEvents: =>
        if @editable
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
        $('.page-wrap .nav.buttons ul').append '<li><button class="positive">Publish Post</button></li>'
        
        editor = new Fora.Editing.Editor()
        editor.editPage if @record.title then '.content' else 'h1'
    

window.Fora.Views.Records.Record = Record
