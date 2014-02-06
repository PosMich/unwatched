# REST Interface Route Definitions
# ================================


debug  = require "./debug"
config = require "./config"

# Route Definitions
# -----------------
exports.route = (app) ->

  # All partials. This is used by Angular.
  app.get "/partials/:name",  (req, res) ->
    name = req.params.name
    res.render "partials/" + name

  # ***
  # ### GET `/`
  # > serve Angular App
  app.get "/", (req, res) ->
    debug.info "send index"
    res.render "layout2.jade"

  # ***
  # ### GET/POST/PUT/DELETE `/*`
  # > Not Found
  app.all "/*", (req, res) ->
    debug.warn "Error 404, not found " + req.url
    res.render "404.jade"
