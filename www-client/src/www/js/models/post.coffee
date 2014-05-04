class Post extends Fora.Models.BaseModel

    constructor: (data) ->
        super
        
    
    getTypeDefinition: =>*
        @typeDefinition
    

window.Fora.Models.Post = Post
