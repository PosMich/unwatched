# Unwatched - Stream Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "StreamCtrl", [
    "$scope", "StreamService"
    ($scope, StreamService) ->

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()
]

app.controller "ScreenCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("screen", $rootScope.userId)

        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

        $scope.item.name = $scope.item.author + "'s Shared Screen"
        StreamService.setScreenItemId($scope.item.id)

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
                StreamService.killScreenStream()
                $location.path "/share"
            )
]

app.controller "WebcamCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$filter",
    "$modal", "StreamService"
    ($scope, $routeParams, SharesService, $location, $filter
        $modal, StreamService) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new image item
            $scope.item = SharesService.create("webcam", $rootScope.userId)

        else
            $scope.item = SharesService.get $routeParams.id
            $location.path "/404" if !$scope.item?

        $scope.item.name = $scope.item.author + "'s Shared Webcam"
        StreamService.setWebcamItemId($scope.item.id)

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
]
