# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "AppCtrl", [
    "$scope"
    "$rootScope"
    "SharesService"
    "StreamService"
    "ChatService"
    "RoomService"
    "UserService"
    "RTCService"
    "FileApiService"
    "$http"
    "ICE_SERVERS"

    ($scope, $rootScope, SharesService, StreamService, ChatService,
        RoomService, UserService, RTCService, FileApiService, $http,
        ICE_SERVERS) ->

        $http(
            method: "GET"
            url: "/turn"
        ).success( (data, status, headers, config) ->
            ICE_SERVERS = createIceServer(
                data.uris
                data.username
                data.password
            )
        ).error( (data, status, headers, config) ->
            console.log "ERROR"
            console.log "data", data
            console.log "status", status
            console.log "headers", headers
            console.log "config", config
        )

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

        window.onbeforeunload = ->
            if !RoomService.isClosed
                return """
                    If you leave this page all of your data in this room will
                    be deleted.
                """

        window.onunload = ->
            # set user to inactive
            #console.log "unloading"
            UserService.getUser($rootScope.userId).isActive = false
            RTCService.sendUserDeleted( UserService.getUser($rootScope.userId) )
            #console.log "deleted user"
            $rootScope.userId = undefined
            $rootScope.roomId = undefined
            FileApiService.suicide()

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

app.controller "AboutCtrl", ->

