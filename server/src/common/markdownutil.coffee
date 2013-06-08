marked = require 'marked'

marked.setOptions {
    gfm: true,
    tables: true,
    breaks: false,
    pedantic: false,
    sanitize: false,
    smartLists: true,
    langPrefix: 'language-',
    highlight: (code, lang) ->
        if (lang is 'js')
            return highlighter.javascript(code)
        return code
}

exports.marked = marked
