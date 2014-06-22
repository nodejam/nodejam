models = require './'
conf = require '../conf'
objects = require '../lib/objects'
UserBase = require('./user-base').UserBase

class User extends UserBase

    save: (context, db) =>*
        { context, db } = @getContext context, db
        
        if not db.getRowId(@)
            existing = yield User.get { @username }, context, db
            if not existing
                @assets = "#{objects.getHashCode(@username) % conf.userDirCount}"
                @lastLogin = 0
                @followingCount = 0
                @followerCount = 0
                yield super 
            else
                throw new Error "User(#{@username}) already exists"
        else
            yield super 

                  
                                                            
    getPosts:(limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Post.find({ 'createdById': db.getRowId(@), state: 'published' }, ((cursor) -> cursor.sort(sort).limit limit), context, db)

        
    
exports.User = User
