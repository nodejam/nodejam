fsutils = require '../../lib/fsutils'

module.exports = ({typeUtils, models, fields, db, conf, auth, mapper, loader }) -> {
    create: auth.handler { session: 'credential' }, ->*

        user = new models.User {
            username: yield* @parser.body('username'),
            credentialId: @session.credentialId,
            name: yield* @parser.body('name'),
            location: yield* @parser.body('location'),
            email: (yield* @parser.body('email') ? 'unknown@foraproject.org'),
            about: yield* @parser.body('about')
            lastLogin: Date.now(),
        }

        user = yield* user.save {}, db

        #Move images to assets 
        picture = {
            src: yield* @parser.body('picture_src'),
            small: yield* @parser.body('picture_small'),
        }
        
        copy = (sourcePath, destFilename) ->*
            [_..., subdir, file] = sourcePath.split('/')
            source = fsutils.getFilePath 'images', subdir, file
            dest = fsutils.getFilePath 'assets', user.assets, destFilename
            yield* fsutils.copyFile source, dest

        yield* copy picture.src, "#{user.username}.jpg"
        yield* copy picture.small, "#{user.username}_t.jpg"

        @body = user.summarize {}, db



    login: auth.handler { session: 'credential' }, ->*
        session = yield* @session.upgrade yield* @parser.body('username')
        
        user = session.user
        user.token = session.token
        
        @cookies.set "userId", user.id.toString(), { httpOnly: false }
        @cookies.set "username", user.username, { httpOnly: false }
        @cookies.set "fullName", user.name, { httpOnly: false }
        @cookies.set "token", session.token
        
        @body = user
    

    item: auth.handler (username) ->*
        user = yield* models.User.get { username }, {}, db        
        if user
            @body = user.summarize {}, db
}

