exports.Cover = require('./cover').Cover
exports.Image = require('./image').Image
exports.Heading = require('./heading').Heading
exports.Text = require('./text').Text
exports.Html = require('./html').Html
exports.Author = require('./author').Author
exports.CardView = require('./cardview').CardView
exports.SingleSectionPage = require('./singlesectionpage').SingleSectionPage
exports.MultiSectionPage = require('./multisectionpage').MultiSectionPage

parse = (data) ->
    if data instanceof Array
        (parse(i) for i in data)
    else if data.widget
        ctor = get(data.widget)
        params = {}
        for k, v of data
            if k isnt 'widget'
                params[k] = parse v
        new ctor params
    else
        data

exports.parse = parse

get = (name) ->
    switch name
        when 'image'
            exports.Image
        when 'cover'
            exports.Cover
        when 'heading'
            exports.Heading
        when 'author'
            exports.Author
        when 'html'
            exports.Html
        when 'text'
            exports.Text
        when 'cardview'
            exports.CardView
        when 'single-section-page'
            exports.SingleSectionPage
        when 'multi-section-page'
            exports.MultiSectionPage
            
exports.get = get
