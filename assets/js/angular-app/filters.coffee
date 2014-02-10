# Unwatched - Angular Filters
# ===========================

"use strict"

app = angular.module("unwatched.filters", [])

app.filter "interpolate", [
  "version"
  (version) ->
    (text) ->
      String(text).replace /\%VERSION\%/g, version
]
