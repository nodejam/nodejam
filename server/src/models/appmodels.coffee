ExtensibleModel = require('../common/data/extensiblemodel').ExtensibleModel

class ExtensibleAppModel extends ExtensibleModel

    fnOld = ExtendedField.describeModel 
    @ExtendedField.describeModel = ->
        result = fnOld()
        result.collection = 'extendedFields'

exports.ExtensibleAppModel = ExtensibleAppModel

