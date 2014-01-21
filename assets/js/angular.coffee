"use strict"

angular.module( "unwatched", [
  "ngRoute",
  "unwatched.filters",
  "unwatched.services",
  "unwatched.directives",
  "unwatched.controllers",
  "ui.bootstrap"
]).config ["$routeProvider", ($routeProvider) ->
  $routeProvider.when "/view1",
  templateUrl: "partials/partial1.jade",
  controller: "MyCtrl1"

  $routeProvider.when "/view2",
  templateUrl: "partials/partial2.jade",
  controller: "MyCtrl2"

  $routeProvider.otherwise redirectTo: "/view1"
]