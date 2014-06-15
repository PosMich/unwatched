# Unwatched - Stream Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "StreamCtrl", [
    "$scope"
    "$routeParams"
    "SharesService"
    "$location"
    "$filter"
    "$modal"
    "StreamService"
    "$rootScope"
    "UserService"
    "RTCService"
    "$timeout"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService, $rootScope, UserService, RTCService, $timeout) ->

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?

            $scope.startSharing = (category) ->
                if $rootScope.isStreaming[category]
                    $location.path "/share/stream/" +
                        $rootScope.streamId[category]
                    return
                # create item
                $scope.item = SharesService.get(
                    SharesService.create $rootScope.userId, category
                )
                $scope.item.name = $scope.user.name + "'s " + category
                #console.log "scope is", $scope

                # request user media
                if category is "screen"
                    video =
                        mandatory:
                            chromeMediaSource: 'screen'
                            maxWidth: 1280,
                            maxHeight: 720
                    audio = false
                else
                    video =
                        mandatory:
                            minWidth: 1280,
                            minHeight: 720
                    audio = true

                userMediaOptions =
                    audio: audio
                    video: video

                successCallback = (stream) ->
                    $scope.item.content = stream
                    stream.onended = ->
                        #console.log "bluibb"
                        $scope.killstream()
                    RTCService.sendNewStream($scope.item, $scope.user.isMaster)
                    angular.element("video").first().on "loadeddata", ->
                        #console.log "scope", $scope
                        #console.log "item", $scope.item
                        # create thumbnail
                        element = angular.element("video").first()
                        canvas = document.createElement("canvas")

                        #console.log "element width is", element.width()

                        max_width = 300
                        width = 1280
                        height = 720

                        if width > max_width
                            height *= max_width / width
                            width = max_width

                        canvas.width = width
                        canvas.height = height

                        #console.log "canvas is", canvas

                        ctx_thumbnail = canvas.getContext "2d"
                        ctx_thumbnail.drawImage(
                            element[0]
                            0
                            0
                            width
                            height
                        )

                        $scope.item.thumbnail = canvas.toDataURL("image/png")

                        #console.log "dataUrl", $scope.item.thumbnail

                        updates =
                            thumbnail: $scope.item.thumbnail

                        RTCService.sendFileHasChanged(updates, $scope.item.id,
                            $scope.user)


                        $location.path("/share/stream/" + $scope.item.id)
                        $rootScope.$apply() if !$rootScope.$$phase
                    $rootScope.$apply() if !$rootScope.$$phase
                errorCallback = (error) ->

                    $scope.captureError = "Unwatched has encountered a " +
                        "problem with this feature. Are you sure you have " +
                        "enabled the chrome-flag <a ng-href=\"chrome://flags" +
                        "/#enable-usermedia-screen-capture\" target='_blank'>" +
                        "#enable-usermedia-screen-capture</a>? You will be " +
                        "redirected to the share overview."
                    $scope.$apply() if !$scope.$$phase

                    $timeout ->
                        SharesService.delete $scope.item.id
                        $location.path "/share"
                        $rootScope.$apply() if !$rootScope.$$phase
                    , 6000

                getUserMedia(userMediaOptions,
                    successCallback, errorCallback)


        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

            path = "/share/stream/" + $rootScope.streamId[$scope.item.category]
            if $location.path() is path
                $rootScope.disableStream[$scope.item.category] = true

            if $scope.item.author isnt $rootScope.userId
                RTCService.requestItem $scope.item.id


        $scope.snapshot = ->
            take =
                snapshot: do -> angular.element("video").first().click()

        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )
            modalInstance.result.then( ->
                $scope.killstream()
            )

        $scope.killstream = ->
            #console.log "blabb"
            id = $scope.item.id
            category = $scope.item.category

            return if !$rootScope.isStreaming[category]

            SharesService.delete id

            $rootScope.isStreaming[category] = false
            $rootScope.streamId[category] = -1

            angular.element("#" + category).src = null

            if $location.path() is "/share/stream/" + id
                $location.path "/share"

            RTCService.sendItemDeleted( $scope.user, $scope.item.id )

            $rootScope.$apply() if !$rootScope.$$phase
        $scope.$watch ->
            $scope.item
        , (newval, oldval) ->
            #console.log "newval", newval
            #console.log "oldval", oldval
            return if !oldval or !newval
            if oldval.content isnt "" and newval.content is ""
                $location.path "/share"
        , true

        $scope.$on "$routeChangeStart", (scope, next, current) ->
            return if !current.scope.item
            $rootScope.disableStream[current.scope.item.category] = false

]
