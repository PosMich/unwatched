# REST Interface Route Definitions
# ================================


debug  = require "./debug"
config = require "./config"

# Route Definitions
# -----------------
exports.route = (app) ->

  debug.info "routes"

  # ***
  # ### GET `/`
  # > serve Angular App
  app.get "/", (req, res) ->
    debug.info "send index"
    res.render "layout.jade"

  # ***
  # ### GET/POST/PUT/DELETE `/*`
  # > Not Found
  app.all "/*", (req, res) ->
    debug.warn "Error 404, not found "+req.url
    res.render "404.jade"
