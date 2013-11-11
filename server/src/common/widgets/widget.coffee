handlebars = require('handlebars')

class Widget
    
    @templateCache = []
    
    parseExpression: (exp, params) =>
        if exp is undefined
            return
        if typeof exp is 'string'
            expArray = exp.split ' '
            if expArray.length is 1
                if expArray[0].substring(0, 1) is '@'
                    field = expArray[0].substring(1)
                    @getFieldValue field, params
                else
                    exp
            else
                switch expArray[0]
                    when 'hbs'
                        for t in Widget.templateCache
                            if t.key is expArray[1]
                                return t.value(params)
                        
                        template = handlebars.compile expArray[1]
                        Widget.templateCache.push { key: expArray[1], value: template }
                        return template(params)
                        
        else
            throw "Unsupported expression."        
                

    getFieldValue: (field, src) =>
        val = src
        for f in field.split('.')
            val = val[f]
            if not val
                return
        return val


    toAttributes: (obj) =>
        attrs = []
        
        for k,v of obj
            attrs.push "#{k}=\"#{v}\""
        
        return attrs.join ' '
    
exports.Widget = Widget
