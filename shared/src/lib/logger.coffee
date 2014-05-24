printError = (err) ->
    if err
        log err.stack ? 'There is no stack trace.'
        if err.details
            log err.details
    else
        log 'Error is null or undefined.'


printStack = ->
    err = new Error
    log err.stack
    

log = (msg) ->
    console.log msg
    
    
module.exports = {
    log,
    printError,
    printStack
}
