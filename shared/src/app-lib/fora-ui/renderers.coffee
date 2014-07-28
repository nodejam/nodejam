React = require('react')

module.exports = {
    simple: {

        ###
            Render a simple app
        ###
        app: (props, context) ->*
            typeDefinition = yield* context.app.getTypeDefinition()

            options = {}
            if context.koaContext.session
                options.loggedIn = true
                membership = yield* context.app.getMembership context.koaContext.session.user.username
                if membership
                    options.isMember = true
                    options.primaryRecordType = "Article" #TODO: This makes no sense

            template = yield* context.extension.getTemplateModule(props.appTemplate)
            props = { records: props.records, app: context.app, appTemplate: props.appTemplate, recordTemplate: props.recordTemplate, options }

            script = "
                <script>
                    var page = new Fora.Views.Page(
                        '/js/extensions/#{typeDefinition.name}/templates/#{props.appTemplate}.js',
                        #{JSON.stringify({ records: props.records, app: context.app, recordTemplate: props.recordTemplate, options })}
                    );
                </script>"

            context.koaContext.body = yield* context.koaContext.render template, "/js/extensions/#{typeDefinition.name}/templates/#{props.appTemplate}", props

        ###
            Render a simple record
        ###
        record: (props, context) ->*
            typeDefinition = yield* context.app.getTypeDefinition()
            author = yield* props.record.getCreator()

            options = {}
            if context.koaContext.session
                options.loggedIn = true

            template = yield* context.extension.getTemplateModule(props.appTemplate)
            props = { record: props.record, app: context.app, author, appTemplate: props.appTemplate, recordTemplate: props.recordTemplate }

            context.koaContext.body = yield* context.koaContext.render template, "/js/extensions/#{typeDefinition.name}/templates/#{props.appTemplate}", props
    }
}
