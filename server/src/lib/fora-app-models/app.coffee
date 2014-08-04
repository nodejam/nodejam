models = require('./')
conf = require '../conf'

AppBase = require('./app-base').AppBase
models = require('./')

class App extends AppBase

    @typeDefinition: ->
        typeDef = AppBase.typeDefinition()
        typeDef.discriminator = (obj) ->*
            def = yield* App.getTypesService().getTypeDefinition(obj.type)
            if def.ctor isnt App
                throw new Error "App type definitions must have ctor set to App"
            def
        typeDef


    save: (context, db) =>*
        { context, db } = @getContext context, db

        #if stub is a reserved name, change it
        if conf.reservedNames.indexOf(@stub) > -1
            throw new Error "Stub cannot be #{@stub}, it is reserved"

            regex = '[a-z][a-z0-9|-]*'
            if not regex.text @stub
                throw new Error "Stub is invalid"

        if not db.getRowId(@)
            @stats = new App.Stats {
                records: 0,
                members: 1,
                lastRecord: 0
            }
            @cache ?= { records: [] }

        yield* super(context, db)



    summarize: (context, db) =>
        summary = new App.Summary {
            id: db.getRowId(@),
            network: @network,
            name: @name,
            stub: @stub,
            createdBy: @createdBy
        }



    getView: (name, context, db) =>*
        switch name
            when 'card'
                {
                    id: db.getRowId(@)
                    @network,
                    @name,
                    @description,
                    @stub,
                    @createdBy,
                    @cache,
                    image: @cover?.image?.small
                }



    join: (user, token, context, db) =>*
        { context, db } = @getContext context, db
        if @access is 'public'
            yield* @addRole user, 'member', context, db
        else
            throw new Error "Access denied"



    addRecord: (record, context, db) =>*
        { context, db } = @getContext context, db
        record.appId = db.getRowId(@)
        record.app = @summarize context, db
        yield* record.save context, db



    getRecord: (stub, context, db) =>*
        { context, db } = @getContext context, db
        yield* models.Record.get({ 'appId': db.getRowId(@), stub }, {}, db)



    getRecords: (limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield* models.Record.find({ 'appId': db.getRowId(@), state: 'published' },  { sort, limit }, context, db)



    addRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db

        membership = yield* models.Membership.get { 'appId': db.getRowId(@), 'user.username': user.username }, context, db
        if not membership
            membership = new models.Membership {
                appId: db.getRowId(@),
                app: @summarize(context, db),
                userId: user.id,
                user,
                roles: [role]
            }
        else
            if membership.roles.indexOf(role) is -1
                membership.roles.push role
        yield* membership.save context, db



    removeRole: (user, role, context, db) =>*
        { context, db } = @getContext context, db
        membership = yield* models.Membership.get { 'appId': db.getRowId(@), 'user.username': user.username }, context, db
        membership.roles = (r for r in membership.roles when r isnt role)
        yield* if membership.roles.length then membership.save() else membership.destroy()



    getMembership: (username, context, db) =>*
        { context, db } = @getContext context, db
        yield* models.Membership.get { 'app.id': db.getRowId(@), 'user.username': username }, {}, db



    getMemberships: (roles, context, db) =>*
        { context, db } = @getContext context, db
        yield* models.Membership.find { 'appId': db.getRowId(@), roles: { $in: roles } }, { sort: { id: -1 }, limit: 200 }, context, db



    refreshCache: (context, db) =>*
        { context, db } = @getContext context, db
        records = yield* @getRecords 10, db.setRowId({}, -1), context, db
        @cache = { records: [] }

        if records.length
            for p in records
                @cache.records.push yield* p.getView("concise", context, db)

            @stats.records = yield* models.Record.count({ 'appId': db.getRowId(@) , state: 'published' }, context, db)
            @stats.lastRecord = records[0].savedAt
            yield* @save context, db

exports.App = App
