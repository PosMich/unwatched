# Unwatched - Index Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "IndexCtrl", [
    "$scope", "$routeParams", "RTCService", "RoomService", "$location",
    "$rootScope", "UserService", "SharesService", "FileService"
    ($scope, $routeParams, RTCService, RoomService, $location,
        $rootScope, UserService, SharesService, FileService) ->

        window.rtcService = RTCService
        window.userService = UserService
        window.sharesService = SharesService
        window.fileService = FileService

        $scope.joinAttempt = false
        $scope.inputDisabled = true

        $scope.room = RoomService
        $scope.room.id = ""

        #console.log webrtcDetectedBrowser

        $rootScope.isChrome = webrtcDetectedBrowser is "chrome"

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
