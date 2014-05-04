class BaseModel

    constructor: (params) ->
        @extend(this, params)


    extend: (target, source, fnCanCopy) ->
        for key, val of source
            if (not target.hasOwnProperty(key)) and ((not fnCanCopy) or fnCanCopy(key))
                target[key] = val
        target

window.Fora.Models.BaseModel = BaseModel
