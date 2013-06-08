class AppError extends Error

    constructor: (@message, @name) ->

    
    toString: =>
        "#{@name}: #{@message}"    
        
exports.AppError = AppError
