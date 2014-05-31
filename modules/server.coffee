express = require "express"
#assets  = require "connect-assets"
http    = require "http"
https   = require "https"
fs      = require "fs"

routes     = require "./routes"
routesAPI  = require "./routes.api"
signalling = require "./signalling"
logger     = require "./logger"
config     = require "./userconfig"


process.on "uncaughtException", (err) ->
    logger.error "OMG :-S"
    logger.error "caught 'uncaught' exception: " + err
    logger.error err.stack


app = express()

#app.port =
#    process.env.PORT or process.env.VMC_APP_PORT or config?.port or 3001

# ***
# ## View initialization

# Set the view engine to jade
app.set "view engine", "jade"
app.set "view options",
    layout: false
# Set ***views*** directory
app.set "views", process.cwd() + "/views"

# Render human readable html
app.locals.pretty = true

app.use require("compression")()
app.use require("serve-static")(process.cwd() + "/public")
app.use require("connect-livereload")(port: 35729)

routes.route app
routesAPI.route app

app.start = ->

    logger.info "server started"
    # create dummy server, should be replaced with a reverse proxy or similar
    http = http.createServer( (req, res) ->
        res.writeHead 301,
            location: "https://#{req.headers["host"].split(":")[0]}:#{config.port.https}#{req.url}"
        res.end()
    )

    https = https.createServer(
        key: fs.readFileSync config.ssl.key
        cert: fs.readFileSync config.ssl.cert
    , app)

    http.listen config.port.http
    https.listen config.port.https

    signalling.connect https
    return
module.exports = app