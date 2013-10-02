ForaDbModel = require('./foramodel').ForaDbModel

class ExtendedField extends ForaDbModel
    @describeType: {
        type: @,
        fields: {
            parentid: 'string',
            field: 'string'
            value: ''
        }
    }
    
exports.ExtendedField = ExtendedField
