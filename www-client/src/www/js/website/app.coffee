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
                props = props
                component = reactClass(props)
                if component.componentInit
                    yield component.componentInit()
            co(setupPage)()
    
            
window.app = new App()

