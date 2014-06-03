# REST Interface Route Definitions
# ================================

logger = require "./logger"

# Route Definitions
# -----------------
exports.route = (app) ->

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
