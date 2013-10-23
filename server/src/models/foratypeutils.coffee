TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    resolveType: (name) =>
        fields = require('./fields')
        switch name
            when 'TextContent'
                fields.TextContent
            when 'Image'
                fields.Image
            else
                super

exports.ForaTypeUtils = ForaTypeUtils
