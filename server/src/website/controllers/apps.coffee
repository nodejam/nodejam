indexView = require('../views/apps/index')

###
    The data structure passed to app extensions.
###

module.exports = ({typeService, models, fields, db, conf, auth, mapper, loader }) -> {

    ###
        Display a list of apps.
    ###
    index: auth.handler ->*
        apps = yield* models.App.find({ network: @network.stub }, { sort: { 'stats.lastRecord': -1 }, limit: 32 }, {}, db)

        for app in apps
            app.summary = yield* app.getView("card", {}, db)

        yield* @render indexView, 'apps/index', { apps }



    ###
        Load the app's extension and pass control to it.
    ###
    page: auth.handler (stub) ->*
        app = yield* models.App.get { stub, network: @network.stub }, {}, db
        if app
            extension = yield* loader.load yield* app.getTypeDefinition()
            pages = yield* extension.getPages()
            yield* pages.handle { app, extension, koaContext: this }


    ###
        Create a new app
    ###
    create: ->*
        yield* @renderPage 'apps/new', {
            pageName: 'create-app-page',
            pageLayout: {
                type: 'single-section-page fixed-width'
            }
        }

}
