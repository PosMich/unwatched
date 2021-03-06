# Unwatched - Angular App
# =======================

"use strict"

app = angular.module "unwatched", [
    "ngRoute"
    "ngAnimate"
    "ngSanitize"
    "angular-intro"
    "unwatched.services"
    "unwatched.directives"
    "unwatched.filters"
    "unwatched.controllers"
    "ui.tinymce"
    "ui.bootstrap"
    "angularFileUpload"
    "ngClipboard"
]


# ***
# ## Config
# > contains routing stuff only (atm)
# >
# > see
# > [angular docs](http://docs.angularjs.org/guide/dev_guide.services.$location)
# > for $locationProvider details
app.config [
    "$provide"
    "$routeProvider"
    "$locationProvider"
    "$compileProvider"
    "ngClipProvider"
    ($provide, $routeProvider, $locationProvider,
        $compileProvider, ngClipProvider) ->

        $locationProvider.html5Mode(true)

        $provide.decorator "$sniffer", ($delegate) ->
            $delegate.history = false
            $delegate

        ngClipProvider.setPath "/swf/ZeroClipboard.swf"
        $compileProvider.aHrefSanitizationWhitelist ///
            ^\s*(https?|ftp|mailto|chrome|filesystem|data):
        ///

        # ### Routes

        # ***
        # * <h3>route `/index`</h3>
        # > this is the `/index` route
        # >
        # > load IndexCtrl
        $routeProvider.when "/",
            templateUrl: "/partials/index.html"
            controller: "IndexCtrl"

        $routeProvider.when "/about",
            templateUrl: "/partials/about.html"
            controller: "AboutCtrl"

        # ***
        # * <h3>route `/room/:id`</h3>
        # > test ro
        # >
        # > load IndexCtrl

        $routeProvider.when "/room/:id",
            controller: "IndexCtrl"
            templateUrl: "/partials/index.html"

        # ***
        # * <h3>route `/index`</h3>
        # > this is the `/index` route
        # >
        # > load IndexCtrl
        $routeProvider.when "/room",
            templateUrl: "/partials/room.html"
            controller: "RoomCtrl"

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
        # $routeProvider.when "/room",
            #templateUrl: "/partials/room.html"
            #controller: "RoomCtrl"
            # templateUrl: "/partials/index.html"
            # controller: "IndexCtrl"
        # ***
        # * <h3>route `/users`</h3>
        # > loads a list of all users of the current room and a maximized chat
        # > window.
        # >
        # > load UsersCtrl
        $routeProvider.when "/users",
            templateUrl: "/partials/users.html"
            controller: "UsersCtrl"

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
            controller: "StreamCtrl"

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
        # > load StreamCtrl
        $routeProvider.when "/share/stream",
            templateUrl: "/partials/items/stream.html"
            controller: "StreamCtrl"

        # ***
        # * <h3>route `/share/screen/:id`</h3>
        # > loads a specific shared screen by the given id
        # >
        # > load StreamCtrl
        $routeProvider.when "/share/stream/:id",
            templateUrl: "/partials/items/stream.html"
            controller: "StreamCtrl"

        # ***
        # * <h3>route `/share/webcam`</h3>
        # > loads an empty webcam item to share it
        # >
        # > load StreamCtrl
        # $routeProvider.when "/share/webcam",
            # templateUrl: "/partials/items/webcam.html"
            # controller: "StreamCtrl"

        # ***
        # * <h3>route `/share/webcam/:id`</h3>
        # > loads a specific shared webcam by the given id
        # >
        # > load StreamCtrl
        # $routeProvider.when "/share/webcam/:id",
            # templateUrl: "/partials/items/webcam.html"
            # controller: "StreamCtrl"

        # ***
        # * <h3>route `/share/file`</h3>
        # > loads an empty file item to share it
        # >
        # > load FileCtrl
        $routeProvider.when "/share/file",
            templateUrl: "/partials/items/file.html"
            controller: "FileCtrl"

        # ***
        # * <h3>route `/share/file/:id`</h3>
        # > loads a specific shared file by the given id
        # >
        # > load FileCtrl
        $routeProvider.when "/share/file/:id",
            templateUrl: "/partials/items/file.html"
            controller: "FileCtrl"

        # ***
        # * <h3>route `/share/image/:id`</h3>
        # > loads an empty image item to share it
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
        $routeProvider.otherwise redirectTo: "/room"


]

app.run ($rootScope, $location) ->

    $rootScope.video = {}
    $rootScope.video.show = {}
    $rootScope.video.show.screen = false
    $rootScope.video.show.webcam = false

    $rootScope.$on "$routeChangeSuccess", ->

        path = $location.path()

        if path isnt "/"
            if !/\/room\/[a-f0-9]+/.test $location.path()
                $rootScope.showChat = true
        else
            $rootScope.showChat = false


        if (path is "/room" and !$rootScope.userId?) or
                (path is "/users" and !$rootScope.userId?) or
                (path.indexOf("/share") > -1 and !$rootScope.userId?)

            $location.path("/")


    return
