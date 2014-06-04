# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "AppCtrl", [
    "$scope", "$rootScope", "SharesService", "StreamService", "ChatService",
    "RoomService", "UserService", "RTCService"
    ($scope, $rootScope, SharesService, StreamService, ChatService,
        RoomService, UserService, RTCService) ->

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

        # window.onbeforeunload = ->
        #     if !RoomService.isClosed
        #         return "If you leave this page all of your data in this room will be deleted."

        window.onunload = ->
            # set user to inactive
            console.log "unloading"
            UserService.getUser($rootScope.userId).isActive = false
            RTCService.sendUserDeleted( UserService.getUser($rootScope.userId) )
            console.log "deleted user"
            $rootScope.userId = undefined
            $rootScope.roomId = undefined

]
