htmlRules = {
    allowedAttributes: ['class'],
    tags: {
        a: { attributes: ['href'] },
        span: {},
        hr: {},
        br: {},
        h1: {},
        h2: {},
        h3: {},
        h4: {},
        h5: {},
        h6: {},
        em: {},
        strong: {},
        table: { children: ['thead', 'tbody', 'tr'] },
        thead: { children: ['tr'] },
        tbody: { children: ['tr'] },
        tr: { children: ['td'] },
        ul: { children: ['li'] },
        ol: { children: ['li'] },
        li: {},
        div: {},
        p: {}
    }
}
