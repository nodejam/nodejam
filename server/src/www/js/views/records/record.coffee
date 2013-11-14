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
        editor = new Fora.Editing.Editor($ '.item')

        $('.edit-options').hide()

        $('.page-wrap').prepend '
            <div class="nav buttons">
                <ul>
                </ul>
            </div>'

        if @record.state is 'published'
            $('.page-wrap .nav.buttons ul').append '<li><button class="cancel">Cancel</button></li>'
            publishText = "Republish"
        else
            publishText = "Publish Post"

        $('.page-wrap .nav.buttons ul').append '<li><button class="delete">Delete</button></li>'
            
        $('.page-wrap .nav.buttons ul').append '<li><button class="publish positive">' + publishText + '</button></li>'

        $('button.publish').click =>
            data = editor.update()
            data.state = 'published'
            $.ajax "/api/forums/#{@record.forum.stub}/records/#{@record._id}", 
                { 
                    type: 'PUT', 
                    data, 
                    success: =>
                        document.location.href = "/#{@record.forum.stub}/#{@record.stub}"
                }
        
        
    
    

window.Fora.Views.Records.Record = Record
