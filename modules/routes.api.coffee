# REST Interface Route Definitions of the Device Database
# =======================================================
logger = require "./logger"


# Route Definitions
# -----------------
# * app -> app/server instance
# * pre -> pre-url like "/api"
exports.route = (app, pre) ->
    # ***
    # ### GET/POST/PUT/DELETE `/*`
    # > Not Found
    app.all pre + "/*", (req, res) ->
        logger.warn "API Error 404, not found ", req.url
        res.send 404, {error: "not found"}
