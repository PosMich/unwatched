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
    "angularFileUpload"
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
    #"RTCProvider"
    ($routeProvider, $locationProvider)->
    #, RTCProvider) ->
    
        #RTCProvider.setName "Alibert"
        #RTCProvider.setSignalServer "wss://localhost"
        
    

        $locationProvider.html5Mode true
        $locationProvider.hashPrefix "!"

        # ### Routes

        # ***
        # * <h3>route `/index`</h3>
        # > this is the `/index` route
        # >
        # > load IndexCtrl
        $routeProvider.when "/",
            templateUrl: "/partials/index.html"
            controller: "IndexCtrl"

        # ***
        # * <h3>route `/cyborg`</h3>
        # > bla bla route to rule them all
        # >
        # > load CyborgCtrl
        $routeProvider.when "/spacelab",
            templateUrl: "/partials/spacelab.html"
            controller: "SpacelabCtrl"

        # ***
        # * <h3>route `/room`</h3>
        # > bla bla route to rule them all
        # >
        # > load RoomCtrl
        $routeProvider.when "/room",
            templateUrl: "/partials/room.html"
            controller: "RoomCtrl"

        # ***
        # * <h3>route `/members`</h3>
        # > loads a list of all members of the current room and a maximized chat
        # > window.
        # >
        # > load MembersCtrl
        $routeProvider.when "/members",
            templateUrl: "/partials/members.html"
            controller: "MembersCtrl"

        # ***
        # * <h3>route `/share`</h3>
        # > loads a list of shared items with interaction possibilities and a
        # > compressed chat window.
        # >
        # > load ShareCtrl
        $routeProvider.when "/share",
            templateUrl: "/partials/share.html"
            controller: "ShareCtrl"

        # ***
        # * <h3>route `/share/screenshot/:id`</h3>
        # > loads a specific shared screenshot by the given id
        # >
        # > load ScreenshotCtrl
        $routeProvider.when "/share/screenshot/:id",
            templateUrl: "/partials/items/screenshot.html"
            controller: "ScreenshotCtrl"

        # ***
        # * <h3>route `/share/note`</h3>
        # > loads an empty note item to edit and share it
        # >
        # > load NoteCtrl
        $routeProvider.when "/share/note",
            templateUrl: "/partials/items/note.html"
            controller: "NoteCtrl"

        # ***
        # * <h3>route `/share/note/:id`</h3>
        # > loads a specific shared note by the given id
        # >
        # > load NoteCtrl
        $routeProvider.when "/share/note/:id",
            templateUrl: "/partials/items/note.html"
            controller: "NoteCtrl"

        # ***
        # * <h3>route `/share/code`</h3>
        # > loads an empty code item to edit and share it
        # >
        # > load CodeCtrl
        $routeProvider.when "/share/code",
            templateUrl: "/partials/items/code.html"
            controller: "CodeCtrl"

        # ***
        # * <h3>route `/share/code/:id`</h3>
        # > loads a specific shared code by the given id
        # >
        # > load CodeCtrl
        $routeProvider.when "/share/code/:id",
            templateUrl: "/partials/items/code.html"
            controller: "CodeCtrl"

        # ***
        # * <h3>route `/share/screen/:id`</h3>
        # > loads an empty screen item to share it
        # >
        # > load SharedScreenCtrl
        $routeProvider.when "/share/screen",
            templateUrl: "/partials/items/screen.html"
            controller: "ScreenCtrl"

        # ***
        # * <h3>route `/share/screen/:id`</h3>
        # > loads a specific shared screen by the given id
        # >
        # > load SharedScreenCtrl
        $routeProvider.when "/share/screen/:id",
            templateUrl: "/partials/items/screen.html"
            controller: "ScreenCtrl"

        # ***
        # * <h3>route `/share/shared-webcam/:id`</h3>
        # > loads a specific shared webcam by the given id
        # >
        # > load SharedWebcamCtrl
        $routeProvider.when "/share/shared-webcam/:id",
            templateUrl: "/partials/items/shared-webcam.html"
            controller: "SharedWebcamCtrl"

        # ***
        # * <h3>route `/share/image/:id`</h3>
        # > loads an empty code item to edit and share it
        # >
        # > load ImageCtrl
        $routeProvider.when "/share/image",
            templateUrl: "/partials/items/image.html"
            controller: "ImageCtrl"

        # ***
        # * <h3>route `/share/image/:id`</h3>
        # > loads a specific shared image by the given id
        # >
        # > load ImageCtrl
        $routeProvider.when "/share/image/:id",
            templateUrl: "/partials/items/image.html"
            controller: "ImageCtrl"

        # ***
        # * <h3>route `/`</h3>
        # > not found - route
        # >
        # > redirect to `/`
        $routeProvider.otherwise redirectTo: "/"
]

app.run ($rootScope, $location) ->

    $rootScope.$on "$routeChangeSuccess", ->
        $rootScope.showChat = $location.path() isnt "/"
        return

    return
