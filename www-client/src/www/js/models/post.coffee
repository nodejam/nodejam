class Post extends Fora.Models.BaseModel

    constructor: (data) ->
        data.content = new Fora.Models.TextContent(data.content)
        super
        
    
    getTypeDefinition: =>*
        @typeDefinition
    

window.Fora.Models.Post = Post
