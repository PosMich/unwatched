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
                    $scope.item =
                        category: category
                    return
                # create item
                $scope.item = SharesService.get(
                    SharesService.create $rootScope.userId, category
                )
                $scope.item.name = $scope.user.name + "'s " + category
                console.log "scope is", $scope

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

                successCallback = (stream) =>
                    $scope.item.content = stream
                    RTCService.sendNewStream($scope.item, $scope.user.isMaster)
                    $location.path("/share/stream/" + $scope.item.id)
                    $rootScope.$apply() if !$rootScope.$$phase

                errorCallback = (error) ->
                    console.log('Failed.', error)

                getUserMedia(userMediaOptions,
                    successCallback, errorCallback)


        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

            if $location.path() is "/share/stream/" + $rootScope.streamId[$scope.item.category]
                $rootScope.disableStream[$scope.item.category] = true


            angular.element("video").first().on "loadeddata", ->
                # create thumbnail
                element = angular.element("video").first()
                canvas = document.createElement("canvas")

                console.log "element width is", element.width()

                max_width = 300
                width = 1280
                height = 720

                if width > max_width
                    height *= max_width / width
                    width = max_width

                canvas.width = width
                canvas.height = height

                console.log "canvas is", canvas

                ctx_thumbnail = canvas.getContext "2d"
                ctx_thumbnail.drawImage( element[0], 0, 0, width, height )

                $scope.item.thumbnail = canvas.toDataURL("image/png")

                console.log "dataUrl", $scope.item.thumbnail

                updates =
                    thumbnail: $scope.item.thumbnail

                RTCService.sendFileHasChanged(updates, $scope.item.id,
                    $scope.user)

                $rootScope.$apply() if $rootScope.$$phase

        $scope.snapshot = ->
            console.log "lkjkl"
            do ->
                angular.element("video").first().click()
                console.log "asdf"

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
                StreamService.killWebcamStream()
                $location.path "/share"
            )

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()


        $scope.$on "$routeChangeStart", (scope, next, current) ->
            $rootScope.disableStream[current.scope.item.category] = false

]
