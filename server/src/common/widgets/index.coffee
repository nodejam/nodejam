exports.Cover = require('./cover').Cover
exports.Image = require('./image').Image
exports.Heading = require('./heading').Heading
exports.Text = require('./text').Text
exports.Html = require('./html').Html
exports.Authorship = require('./authorship').Authorship
exports.PostView = require('./postview').PostView
exports.CardView = require('./cardview').CardView

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
        when 'authorship'
            exports.Authorship
        when 'html'
            exports.Html
        when 'text'
            exports.Text
        when 'postview'
            exports.PostView
        when 'cardview'
            exports.CardView
            
exports.get = get
