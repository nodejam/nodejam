class Post

    constructor: (@post, @typeDefinition) ->        
        $(document).ready () =>
            @editable = app.getUser()?.id is @post.createdBy.id
            if @editable
                $('.main-pane').prepend '                
                    <p class="option-bar">
                        <button><i class="settings icon-cog"></i>Settings</button>
                        <button class="edit positive">Edit Post</button>
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

        if @post.state is 'published'
            $('.page-wrap .nav.buttons ul').append '<li><button class="cancel">Cancel</button></li>'
            publishText = "Republish"
        else
            publishText = "Publish Post"

        $('.page-wrap .nav.buttons ul').append '<li><button class="delete">Delete</button></li>'
            
        $('.page-wrap .nav.buttons ul').append '<li><button class="publish positive">' + publishText + '</button></li>'

        $('button.publish').click =>
            data = editor.data()
            data.state = 'published'
            $.ajax "/api/forums/#{@post.forum.stub}/posts/#{@post._id}", 
                { 
                    type: 'PUT', 
                    data, 
                    success: =>
                        document.location.href = "/#{@post.forum.stub}/#{@post.stub}"
                }
        
        
    
    

window.Fora.Views.Posts.Post = Post
