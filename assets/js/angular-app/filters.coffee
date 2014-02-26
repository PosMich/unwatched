# Unwatched - Angular Filters
# ===========================

"use strict"

app = angular.module("unwatched.filters", [])

# ***
# * <h3>iif</h3>
# > Filter for immediate if - aka iif
# > Frontend-usage: {{confition | iif : "it's true" : "it's false"}}
app.filter "iif", [ ->
  (input, trueValue, falseValue) ->
    (if input then trueValue else falseValue)
]

app.filter "interpolate", [
  "version"
  (version) ->
    (text) ->
      String(text).replace /\%VERSION\%/g, version
]
