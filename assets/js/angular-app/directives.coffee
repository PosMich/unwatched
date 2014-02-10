# Unwatched - Angular Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives", []

app.directive "appVersion", [
  "version"
  (version) ->
    (scope, elm, attrs) ->
      elm.text version
]
