exports.getTemplate = (name) -> 
    switch name
        when 'standard'
            {
                widget: "single-section-page",
                cover: { cover: '@post.cover', field: 'cover',  editable: true, size: 1 },
                mainPane: [                    
                    { widget: 'heading', title: '@post.title', field: 'title', editable: true, size: 1 },
                    { widget: 'authorship', type: 'small', author: '@author' },
                    { widget: 'text', text: '@post.content', field: 'content', editable: true },
                ],
                sidebar: [ { widget: 'authorship', author: '@author' } ]
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
        else
            throw new Error "Unknown template type"
            


exports.getView = (name) ->
    switch name
        when "snapshot"
            {
                image: @cover?.image.small,
                @title,
                @createdBy,
                id: @_id.toString(),
                @stub
            }
        else
            throw new Error "Unknown snapshot type"
