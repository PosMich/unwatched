# Angular Filters
# =======================================================

"use strict"

angular.module("unwatched.filters", [])
.filter "interpolate", ["version", (version) ->
  (text) ->
    String(text).replace /\%VERSION\%/g, version
]