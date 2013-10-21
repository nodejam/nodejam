TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    resolveType: (name) =>
        fields = require('./fields')
        switch name
            when 'TextContent'
                fields.TextContent
            when 'CoverPicture'
                fields.CoverPicture
            else
                super

exports.ForaTypeUtils = ForaTypeUtils
