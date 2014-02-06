# Unwatched - Angular Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives", []

app.directive "appVersion",
  (version) ->
    (scope, elm, attrs) ->
      elm.text version

