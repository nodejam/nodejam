
module.exports = ({typeUtils, models, fields, db, conf, auth, mapper, loader }) -> {

    create: auth.handler { session: 'user' }, ->*
        context = { user: @session.user }
        stub = (yield* @parser.body 'name').toLowerCase().trim()

        if conf.reservedNames.indexOf(stub) > -1
            stub = stub + "-app"
        stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')

        app = yield* models.App.get({ network: @network.stub, $or: [{ stub }, { name: yield* @parser.body('name') }] }, context, db)

        if app
            throw new Error "App exists"
        else
            app = yield* models.App.create {
                type: yield* @parser.body('type'),
                name: yield* @parser.body('name'),
                access: yield* @parser.body('access'),
                network: @network.stub,
                stub,
                createdById: @session.user.id,
                createdBy: @session.user,
            }

            yield* @parser.map app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']
            yield* @parser.map app, yield* mapper.getMappableFields yield* app.getTypeDefinition()
            app = yield* app.save context, db
            yield* app.addRole @session.user, 'admin'
            this.body = app


    edit: auth.handler { session: 'user' }, (app) ->*
        context = { user: @session.user }
        app = yield* models.App.get { stub: app, network: @network.stub }, { user: @session.user }, db

        if (@session.user.username is app.createdBy.username) or @session.admin
            yield* @parser.map app, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']
            yield* @parser.map app, yield* mapper.getMappableFields yield* app.getTypeDefinition()
            app = yield* app.save()
            @body = app
        else
            @throw "access denied", 403


    join: auth.handler { session: 'user' }, (app) ->*
        app = yield* models.App.get { stub: app, network: @network.stub }, { user: @session.user }, db
        yield* app.join @session.user
        @body = { success: true }

}
