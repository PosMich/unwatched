"use strict"

app = angular.module "unwatched", [
  "ngRoute"
  "unwatched.filters"
  "unwatched.services"
  "unwatched.directives"
  "unwatched.controllers"
  "ui.bootstrap"
]


app.config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true

    $routeProvider.when "/index",
      templateUrl: "partials/index.jade"
      controller: "IndexCtrl"
    $routeProvider.when "/cyborg",
      templateUrl: "partials/cyborg.jade"
      controller: "CyborgCtrl"

    $routeProvider.otherwise redirectTo: "/"
]
