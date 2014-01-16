# ## Dependencies

# ---
# ### packages
# installed via `npm install`
express  = require "express"
assets   = require "connect-assets"
partials = require "express-partials"
stylus   = require "stylus"

# ---
# ### own modules
# located in same directory as the server.coffee file
config    = require "./config"
debug     = require "./debug"

routesAPI = require "./routes.api"
routes    = require "./routes"

# ---
# print unused exceptions
process.on "uncaughtException", (err) ->
  debug.error "OMG :-S"
  debug.error "caught 'uncaught' exception: " + err



# ---
# ## Basic application initialization
# Create server instance.
server = express()

# Define Port
server.port = process.env.PORT or process.env.VMC_APP_PORT or config.PORT or 3000

# Config module exports has `setEnvironment` function that sets server settings depending on environment.
server.configure "production", "development", "testing", ->
  config.setEnvironment server.settings.env

# ---
# ## View initialization
server.use express.logger("dev")
# Add Connect Assets.
server.use assets()
# Compress responses
server.use express.compress()
# Add Partials
server.use partials()
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
server.use express.favicon( process.cwd()+"public/favicon.ico")


# ---
# This function will pass the current url to the template object.
# It allows us to use this value for the navbar.
server.use (req, res, next) ->
  # ***
  # > set cookie max age to 14 days
  req.session.cookie.maxAge = 14 * 24 * 60 * 60 * 1000

  next()

# Set the view engine to ejs
server.set "view engine", "jade"
server.set "view options",
  layout: false

# Set ***views*** directory
server.set "views", process.cwd() + "/views"

# [Body parser middleware or better known as the random link, everyone needs](http://www.senchalabs.org/connect/middleware-bodyParser.html) parses JSON or XML bodies into `req.body` object
# force UploadDir to be /tmp
#server.use express.bodyParser <-- causing a problem!!!

# ---
# ## Add routes
routesAPI.route server, "/api"
routes.route server


# ---
# ## Server start
server.start = ->
  # Start Server
  server.listen server.port, ->
    console.log "Listening on " + server.port + "\nPress CTRL-C to stop server."

# Export server object
module.exports = server
