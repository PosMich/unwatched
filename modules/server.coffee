###
# ## Dependencies

# ***
# ## # packages
# installed via `npm install`
express  = require "express"
assets   = require "connect-assets"
stylus   = require "stylus"

# ***
# ## # own modules
# located in same directory as the server.coffee file
config    = require "./config"
debug     = require "./debug"

routesAPI = require "./routes.api"
routes    = require "./routes"

# ***
# print unused exceptions
process.on "uncaughtException", (err) ->
  debug.error "OMG :-S"
  debug.error "caught 'uncaught' exception: " + err
  console.log err.stack


# ***
# ## Basic application initialization
# Create server instance.
server = express()

# Define Port
server.port =
  process.env.PORT or process.env.VMC_APP_PORT or config.port or 3000

# Config module exports has `setEnvironment` function that sets server settings
# depending on environment.
config.setEnvironment server.settings.env

# ***
# ## View initialization
server.use express.logger("dev")
# Set the view engine to jade
server.set "view engine", "jade"
server.set "view options",
  layout: false
# Set ***views*** directory
server.set "views", process.cwd() + "/views"
# Add Connect Assets.
server.use assets
  # [bugifx](https://github.com/adunkman/connect-assets/issues/221)
  helperContext: server.locals
  buildDir: "public"
# Render human readable html
server.locals.pretty = true


# Compress responses
server.use express.compress()

# Add Session Cookie
server.use express.cookieParser()
# Enable Sessions


server.use express.session(
  "secret": config.sessionSecret
  "cookie":
    "maxAge": 365 * 24 * 60 * 60 * 1000
    "expires": false
)

# Set the ***public*** folder as static assets.
server.use express.static(process.cwd() + "/public")

# Set the favicon
server.use express.favicon( process.cwd() + "public/favicon.ico")


# ***
# This function will pass the current url to the template object.
# It allows us to use this value for the navbar.
server.use (req, res, next) ->
  # ***
  # > set cookie max age to 14 days
  req.session.cookie.maxAge = 14 * 24 * 60 * 60 * 1000

  next()



# [Body parser middleware or better known as the random link, everyone needs]
# (http://www.senchalabs.org/connect/middleware-bodyParser.html)
# parses JSON or XML bodies into `req.body` object
# force UploadDir to be /tmp
#server.use express.bodyParser <-- causing a problem!!!

# ---
# ## Add routes
routesAPI.route server, "/api"
routes.route server


# ***
# ## Server start
server.start = ->
  # Start Server
  server.listen server.port, ->
    console.log "Listening on " + server.port + "\nPress CTRL-C to stop server."

# Export server object
module.exports = server
###

process.on "uncaughtException", (err) ->
    debug.error "OMG :-S"
    debug.error "caught 'uncaught' exception: " + err
    console.log err.stack

express = require "express"
assets  = require "connect-assets"

config    = require "./config"
debug     = require "./debug"
routes    = require "./routes"
routesAPI = require "./routes.api"

app = express()

app.port =
    process.env.PORT or process.env.VMC_APP_PORT or config?.port or 3000

# ***
# ## View initialization
#app.use express.logger("dev")
# Set the view engine to jade
app.set "view engine", "jade"
app.set "view options",
    layout: false
# Set ***views*** directory
app.set "views", process.cwd() + "/views"
# Add Connect Assets.


#app.use assets
  # [bugifx](https://github.com/adunkman/connect-assets/issues/221)
#  helperContext: app.locals
#  buildDir: "public"

# Render human readable html
app.locals.pretty = true

app.use require("compression")()
app.use require("serve-static")(process.cwd() + "/public")
app.use require("connect-livereload")(port: 35729)

routes.route app
routesAPI.route app


app.start = ->
    app.listen app.port, ->
        console.log "Listening on " + app.port + "\nPress CTRL-C to stop server."

module.exports = app