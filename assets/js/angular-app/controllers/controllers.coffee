# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "AppCtrl", [
    "$scope", "$rootScope", "SharesService", "StreamService", "ChatService",
    "RoomService"
    ($scope, $rootScope, SharesService, StreamService, ChatService,
        RoomService) ->

        $scope.isClosed = false

        # init stream
        $rootScope.isStreaming =
            webcam: false
            screen: false

        $rootScope.streamId =
            webcam: -1
            screen: -1

        $rootScope.disableStream =
            webcam: false
            screen: false

        $rootScope.screenshotCountdown = -1

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()

        $scope.$watch ->
            RoomService.isClosed
        , (isClosed) ->
            if isClosed
                $scope.isClosed = isClosed
                window.setTimeout((->
                    window.location = "/"
                ), 5000)

]

app.controller "DeleteModalInstanceCtrl", [
    "$scope", "$modalInstance", "item", "UserService"
    ($scope, $modalInstance, item, UserService) ->
        $scope.item = item
        $scope.users = UserService.users

        $scope.ok = ->
            $modalInstance.close()

        $scope.cancel = ->
            $modalInstance.dismiss('cancel')

]
