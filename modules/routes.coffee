# REST Interface Route Definitions
# ================================

logger = require "./logger"

# Route Definitions
# -----------------
exports.route = (app) ->
  # All partials. This is used by Angular.
  app.get "/partials/:name",  (req, res) ->
    name = req.params.name

    logger.info "render #{req.params.name} partial", 
      url: req.url
      params: req.params
    
    res.render "partials/" + name

  # All item partials. This is used by Angular.
  app.get "/partials/:dir/:name",  (req, res) ->
    name = req.params.name
    dir  = req.params.dir

    logger.info "render #{dir}/#{name} partial", 
      url: req.url
      params: req.params
    
    res.render "partials/#{dir}/#{name}" 


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
