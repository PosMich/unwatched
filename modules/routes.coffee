# REST Interface Route Definitions
# ================================


# Route Definitions
# -----------------
exports.route = (app) ->
  # All partials. This is used by Angular.
  app.get "/partials/:name",  (req, res) ->
    name = req.params.name
    res.render "partials/" + name

  # All item partials. This is used by Angular.
  app.get "/partials/items/:name",  (req, res) ->
    name = req.params.name
    res.render "partials/items/" + name


  # ***
  # ### GET `*`
  # > serve Angular App
  app.get "*", (req, res) ->
    res.render "layout.jade"


  # ***
  # ### POST/PUT/DELETE `*`
  # > Not Found
  app.all "*", (req, res) ->
    #debug.warn "Error 404, not found " + req.url
    res.render "404.jade"
