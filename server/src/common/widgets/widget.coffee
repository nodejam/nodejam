class Widget

    getValue: (src, field) =>
        val = src
        for f in field.split('.')
            val = src[f]
            if not val
                return
        return val
    
exports.Widget = Widget
