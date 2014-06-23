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

                reactClass = require(pageName)
                if reactClass.componentInit
                    props = yield reactClass.componentInit props
                component = reactClass(props)
                
            co(setupPage)()
    
            
window.app = new App()

