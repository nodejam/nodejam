class TextContent extends Fora.Models.BaseModel

    constructor: (data) ->
        super
        
    
    getTypeDefinition: =>*
        @typeDefinition
    

    formatContent: =>
        switch @format
            when 'markdown'
                if @text then markdown.toHTML(@text) else ''
            when 'html', 'text'
                @text
            else
                'Invalid format.'


window.Fora.Models.TextContent = TextContent
