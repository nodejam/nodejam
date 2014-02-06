koa = require 'koa'
favicon = require 'koa-favicon'
route = require 'koa-route'
hbs = require 'koa-hbs'
utils = require '../lib/utils'
init = require '../common/web/init'

process.chdir __dirname

host = process.argv[2]
port = process.argv[3]

if not host or not port
    utils.log "Usage: app.js host port"
    process.exit()

utils.log "Fora Website started at #{new Date} on #{host}:#{port}"

app = koa()
init app
app.use favicon()

app.use hbs.middleware {
  viewPath: __dirname + '/views',
  partialsPath: __dirname + '/views/partials',
  layoutsPath: __dirname + '/views/layouts',
  defaultLayout: 'default'
}

#Routes
m_home = require './controllers/home'
m_auth = require './controllers/auth'
m_users = require './controllers/users'
m_forums = require './controllers/forums'
m_posts = require './controllers/posts'

app.use route.get '/healthcheck', -> this.body { "Jack Sparrow is alive" }

app.use route.get '/', m_home.index
app.use route.get '/login', m_home.login

app.use route.get '/auth/twitter', m_auth.twitter
app.use route.get '/auth/twitter/callback', m_auth.twitterCallback

app.use route.get '/forums', m_forums.index
app.use route.get '/forums/new', m_forums.create

app.use route.get '/users/selectusername', m_users.selectUsernameForm
app.use route.post '/users/selectusername', m_users.selectUsername
app.use route.post '/~:username', m_users.item

app.use route.get '/:forum', m_forums.item
app.use route.get '/:forum/about', m_forums.about
app.use route.get '/:forum/:post', m_posts.item
    
#Register templates, helpers etc.
require("./hbshelpers").register()

#Start
app.listen port
