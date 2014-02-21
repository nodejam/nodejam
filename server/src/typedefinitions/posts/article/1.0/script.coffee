exports.save = ->*
    @cover?.type ?= 'inline-cover'
    
    

exports.getTemplate = (name) ->*
    switch name
    
        when 'item'
            {
                widget: "single-section-page",
                theme: { theme: "@post.theme", field: "theme" }
                cover: { widget: 'cover', cover: '@post.cover', field: 'cover' },
                title: { widget: 'heading', title: '@post.title', field: 'title', size: 1 },
                author: { widget: 'author', author: '@author', type: 'small' },
                contents: [
                    { widget: 'text', text: '@post.content', field: 'content' },
                ]
            }
    
        when 'card'
            cardFace = []
            
            if @cover
                cardFace.push { widget: "image", image: '@post.cover.image', type: 'small', bg: true }
            else
                cardFace.push { 
                    widget: "html", 
                    html: "<div class=\"content-wrap\">Hello World</div>"
                }
                
            {
                widget: "cardview",
                cardFace,
                content: [
                    { widget: "heading", size: 2, title: '@post.title', link: "/#{@forum.stub}/#{@stub}" },
                ]
            }
            


exports.getView = (name) ->*
    switch name    
        when "concise"
            {
                image: @cover?.image.small,
                @title,
                @createdBy,
                id: @_id.toString(),
                @stub
            }

