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
  "$routeProvider", "$locationProvider"
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