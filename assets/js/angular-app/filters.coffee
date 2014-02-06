# Angular Filters
# =======================================================

"use strict"

app = angular.module("unwatched.filters", [])

app.filter "interpolate",
  (version) ->
    (text) ->
      String(text).replace /\%VERSION\%/g, version
