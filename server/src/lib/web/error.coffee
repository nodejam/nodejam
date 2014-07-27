argv = require('optimist').argv

module.exports = (app) ->
    app.on "error", (err, ctx) ->
        printer = if argv.showerrors then console.log else console.error
        printer.call console, err
        printer.call console, err.stack
        if err._inner
            printer.call console, err._inner
            printer.call console, err._inner.stack
