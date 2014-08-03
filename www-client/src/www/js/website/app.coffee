co = require('co');
React = require('react')

models = require('../models')
fields = require('../models/fields')
ForaTypesService = require('../models/foratypeutils')

class App

    initPage: (pageName, props) =>
        document.addEventListener 'DOMContentLoaded', ->
            setupPage = ->*

                typesService = new ForaTypesService()
                yield* typesService.init([models, fields], models.App, models.Record)

                reactClass = require(pageName)
                if reactClass.componentInit
                    props = yield* reactClass.componentInit props
                component = reactClass(props)
                React.renderComponent(component, document.getElementsByClassName("page-container")[0])

            co(setupPage)()


window.app = new App()
