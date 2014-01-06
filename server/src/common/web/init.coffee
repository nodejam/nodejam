parser = require '../../lib/web/requestparser'
ForaTypeUtils = require('../../models/foratypeutils').ForaTypeUtils
conf = require '../../conf'

module.exports = (app) ->
    app.use (next) ->*
        if @method is 'POST' or @method is 'PUT' or @method is 'PATCH'
            @parser =  new parser.RequestParser(@, new ForaTypeUtils)
            yield @parser.init()

        network = (n for n in conf.networks when n.domains.indexOf(@host) isnt -1)
        if network.length
            @network = network[0]
        
        yield next
