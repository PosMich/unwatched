# Unwatched - Stream Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "StreamCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal", "StreamService", "$rootScope", "UserService"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService, $rootScope, UserService) ->

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?

            $scope.startSharing = (category) ->
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
                    audio = false
                else
                    video = true
                    audio = true

                userMediaOptions =
                    audio: audio
                    video: video

                successCallback = (stream) =>
                    console.log "scope is in succesCb", $scope
                    console.log "item is before stream", $scope.item
                    console.log "successCallback, stream is ", stream
                    $scope.item.content = stream
                    console.log "successCallback, content is ", $scope.item.content
                    $rootScope.$apply() if !$rootScope.$$phase
                    console.log "item is after stream", $scope.item

                errorCallback = (error) ->
                    console.log('Failed.', error)

                getUserMedia(userMediaOptions,
                    successCallback, errorCallback)

                # item.content = stream

        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?



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

]
