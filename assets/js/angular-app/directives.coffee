# Angular Directives
# =======================================================

"use strict"

angular.module("unwatched.directives", [])
.directive "appVersion", ["version", (version) ->
  (scope, elm, attrs) ->
    elm.text version
]
