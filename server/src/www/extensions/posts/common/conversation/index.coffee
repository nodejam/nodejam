require 'api'

module.exports = {
    type: {
        name: 'Article',
        fields: {
            title: { type: 'string', required: false, maxLength: 200 }
            subtitle: { type: 'string', required: false, maxLength: 200 },
            synopsis: { type: 'string', required: false, maxLength: 2000 },
            cover: 'cover !required',
            content: 'text-content !required'
        }
    }
    
    template: () ->
        
        
}
