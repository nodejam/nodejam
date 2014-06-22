co = require('co');

class App

    initPage: (pageName, props) =>
        document.addEventListener 'DOMContentLoaded', ->
            setupPage = ->*

                models = require('../models')
                fields = require('../models/fields')
                ForaTypeUtils = require('../models/foratypeutils')
                typeUtils = new ForaTypeUtils()
                yield typeUtils.init([models, fields], models.Forum, models.Post)

                reactModule = require(pageName)
                if reactModule.init
                    props = yield reactModule.init props
                component = reactModule.component(props)
            co(setupPage)()
    
            
window.app = new App()

