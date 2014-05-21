# Unwatched - Angular App
# =======================

"use strict"

app = angular.module "unwatched", [
  "ngRoute"
  "ngAnimate"
  "ngSanitize"
  "unwatched.services"
  "unwatched.directives"
  "unwatched.filters"
  "unwatched.controllers"
  "ui.tinymce"
  "ui.bootstrap"
  "ngFitText"
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
    RTCProvider.setSignalServer "wss://localhost"
    

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
    # * <h3>route `/members`</h3>
    # > loads a list of all members of the current room and a maximized chat
    # > window.
    # >
    # > load RoomCtrl
    $routeProvider.when "/members",
      templateUrl: "partials/members.jade"
      controller: "MembersCtrl"

    # ***
    # * <h3>route `/share`</h3>
    # > loads a list of shared items with interaction possibilities and a
    # > compressed chat window.
    # >
    # > load RoomCtrl
    $routeProvider.when "/share",
      templateUrl: "partials/share.jade"
      controller: "ShareCtrl"

    # ***
    # * <h3>route `/`</h3>
    # > not found - route
    # >
    # > redirect to `/`
    $routeProvider.otherwise redirectTo: "/"
]
