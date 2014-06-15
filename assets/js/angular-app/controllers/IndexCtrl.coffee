# Unwatched - Index Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "IndexCtrl", [
    "$scope"
    "$routeParams"
    "RTCService"
    "RoomService"
    "$location"
    "$rootScope"
    "UserService"
    "SharesService"
    "FileApiService"
    "$http"
    "ICE_SERVERS"
    ($scope, $routeParams, RTCService, RoomService, $location,
        $rootScope, UserService, SharesService, FileApiService, $http,
        ICE_SERVERS) ->
        console.log "blubb index blubb"

        window.rtcService = RTCService
        window.userService = UserService
        window.sharesService = SharesService
        window.fileApiService = FileApiService

        $scope.joinAttempt = false
        $scope.inputDisabled = true

        $scope.room = RoomService
        $scope.room.id = ""

        #console.log webrtcDetectedBrowser

        $rootScope.isChrome = webrtcDetectedBrowser is "chrome"



        $http(
            method: "GET"
            url: "/turn"
        ).success( (data, status, headers, config) ->
            console.log "store ice servers", data
            ICE_SERVERS[1] = window.createIceServers(
                data.uris
                data.username
                data.password
            )
            console.log "stored ice servers", ICE_SERVERS

            if $routeParams.id
                $scope.joinAttempt = true
                RTCService.setup($routeParams.id)

                $scope.$watch ->
                    RTCService.handler.dataChannel
                , (value) ->
                    #console.log value
                    if value
                        $scope.inputDisabled = false
                , true

                $scope.$watch ->
                    RTCService.handler.passwordIsValid
                , (value) ->
                    if value
                        $location.path "/room"
                    else
                        console.log "auth issue", value

        ).error( (data, status, headers, config) ->
            console.log "ERROR"
            console.log "data", data
            console.log "status", status
            console.log "headers", headers
            console.log "config", config
        )



        $scope.joinRoom = ->
            if $scope.joinRoomForm.$valid
                # future password validation
                RTCService.checkPassword $scope.room.joinPassword


        $scope.submitRoom = ->
            if $scope.createRoom.$valid
                RTCService.setup()
                RTCService.setPassword $scope.room.password

                $scope.$watch ->
                    RTCService.handler.roomId
                , (value) ->
                    if value && value isnt ''
                        $scope.room.id = value
                        RoomService.setName $scope.room.name
                        RoomService.setUrl( "/room/" + $scope.room.id )
                        $rootScope.userId = UserService.addUser("Unnamed", true)
                        $location.path "/room"

                , true

]
