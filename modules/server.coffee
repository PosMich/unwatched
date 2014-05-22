express = require "express"
assets  = require "connect-assets"
http    = require "http"
https   = require "https"
fs      = require "fs"

routes    = require "./routes"
routesAPI = require "./routes.api"
signaling = require "./signaling"
logger    = require "./logger"
config    = require "./userconfig"


process.on "uncaughtException", (err) ->
    console.log "OMG :-S"
    console.log "caught 'uncaught' exception: " + err
    console.log err.stack


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
    # create dummy server, should be replaced with a reverse proxy or similar
    http = http.createServer( (req, res) ->
        res.writeHead 301,
            location: "https://#{req.headers["host"].split(":")[0]}:3001#{req.url}"
        res.end()
    )

    https = https.createServer(    
        key: fs.readFileSync "cert/server.key"
        cert: fs.readFileSync "cert/server.crt"
    , app)

    http.listen 3000
    https.listen 3001
    ###
    signaling.connect app
    ###
module.exports = app