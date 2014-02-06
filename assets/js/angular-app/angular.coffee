"use strict"

unwatchedApp = angular.module( "unwatched", [
  "ngRoute"
  "unwatched.filters"
  "unwatched.services"
  "unwatched.directives"
  "unwatched.controllers"
  "ui.bootstrap"
])

unwatchedApp.config [
  "$routeProvider"
  ($routeProvider) ->
    $routeProvider.when("/index",
      templateUrl: "partials/index.jade"
      controller: "IndexCtrl"
    ).when("/cyborg",
      templateUrl: "partials/cyborg.jade"
      controller: "CyborgCtrl"
    ).otherwise redirectTo: "/"
]