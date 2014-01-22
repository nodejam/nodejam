module.exports = {
    name: 'article',
    schema: {
        type: 'object',
        properties: {
            title: { type: 'string', maxLength: 200 },
            subtitle: { type: 'string', maxLength: 200 },
            synopsis: { type: 'string', maxLength: 2000 },
            cover: { $ref: 'cover' },
            content: { $ref: 'text-content' },
        },
        required: ['title']
    }
}


