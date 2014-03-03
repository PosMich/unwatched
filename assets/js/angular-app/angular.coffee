# Unwatched - Angular App
# =======================

"use strict"

app = angular.module "unwatched", [
  "ngRoute"
  "unwatched.services"
  "unwatched.directives"
  "unwatched.filters"
  "unwatched.controllers"
  "ui.bootstrap"
]

# ***
# ## Config
# > contains routing stuff only (atm)
# >
# > see
# > [angular docs](http://docs.angularjs.org/guide/dev_guide.services.$location)
# > for $locationProvider details
app.config [
  "$routeProvider"
  "$locationProvider"
  "RTCProvider"
  ($routeProvider, $locationProvider, RTCProvider) ->
    RTCProvider.setName "Alibert"

    $locationProvider.html5Mode true
    $locationProvider.hashPrefix "!"

    # ### Routes

    # ***
    # * <h3>route `/index`</h3>
    # > this is the `/index` route
    # >
    # > load IndexCtrl
    $routeProvider.when "/",
      templateUrl: "partials/index.jade"
      controller: "IndexCtrl"

    # ***
    # * <h3>route `/cyborg`</h3>
    # > bla bla route to rule them all
    # >
    # > load CyborgCtrl
    $routeProvider.when "/spacelab",
      templateUrl: "partials/spacelab.jade"
      controller: "SpacelabCtrl"

    # ***
    # * <h3>route `/room`</h3>
    # > bla bla route to rule them all
    # >
    # > load RoomCtrl
    $routeProvider.when "/room",
      templateUrl: "partials/room.jade"
      controller: "RoomCtrl"

    # ***
    # * <h3>route `/`</h3>
    # > not found - route
    # >
    # > redirect to `/`
    $routeProvider.otherwise redirectTo: "/"
]
