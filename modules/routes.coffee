# REST Interface Route Definitions
# ================================
https = require "https"

logger = require "./logger"



# Route Definitions
# -----------------
exports.route = (app) ->
    # ***
    # ### GET `/turn`
    # > serve Angular App
    app.get "/turn", (req, res) ->
        logger.info "got '/turn'", req.url

        https.get
            host: "computeengineondemand.appspot.com"
            path: "/turn?username=1&key=1"
        , (https_res) ->
            data = ""

            https_res.on "data", (chunk) ->
                data += chunk

            https_res.on "end", ->
                res.send JSON.parse(data)


    # ***
    # ### GET `*`
    # > serve Angular App
    app.get "*", (req, res) ->
        logger.info "got *", req.url
        res.render "layout.jade"


    # ***
    # ### POST/PUT/DELETE `*`
    # > Not Found
    app.all "*", (req, res) ->
        logger.warn "Error 404, not found", req.url
        res.render "404.jade"
