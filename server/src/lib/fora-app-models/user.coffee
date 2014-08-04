models = require './'
typeHelpers = require 'fora-type-helpers'
UserBase = require('./user-base').UserBase

class User extends UserBase

    save: (context, db) =>*
        { context, db } = @getContext context, db

        if not db.getRowId(@)
            existing = yield* User.get { @username }, context, db
            if not existing
                conf = services.get('configuration')
                @assets = "#{typeHelpers.getHashCode(@username) % conf.userDirCount}"
                @lastLogin = 0
                @followingCount = 0
                @followerCount = 0
                yield* super
            else
                throw new Error "User(#{@username}) already exists"
        else
            yield* super



    getRecords:(limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield* models.Record.find({ 'createdById': db.getRowId(@), state: 'published' }, ((cursor) -> cursor.sort(sort).limit limit), context, db)



exports.User = User
