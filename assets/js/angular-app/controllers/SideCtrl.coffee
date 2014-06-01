# Unwatched - Side Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "SideCtrl", [
    "$scope", "UserService", "SharesService", "ChatService", "$location",
    "RoomService", "RTCService", "$rootScope"
    ($scope, UserService, SharesService, ChatService, $location,
        RoomService, RTCService, $rootScope) ->

        $scope.isInRoom = RoomService.id != ""
        $scope.roomUrl = "/"

        $scope.$watch ->
            RoomService.id
        , (value) ->
            $scope.isInRoom = RoomService.id != ""
            $scope.roomUrl = "/"
            $scope.roomUrl = "/room" if $scope.isInRoom

        $scope.messages = []
        $scope.users = UserService.users
        $scope.usersNotification = 0
        $scope.shares = SharesService.shares
        $scope.sharesNotification = 0

        $scope.$watch ->
            ChatService.messages
        , (messages) ->
            max_messages = messages.length
            max_messages = 4 if messages.length >= 4
            $scope.messages = messages.slice(
                messages.length - max_messages, messages.length
            )
        , true

        $scope.$watch ->
            UserService.users
        , (new_users, old_users) ->
            if new_users.length isnt old_users.length
                if $location.path() isnt "/users"
                    $scope.usersNotification++
        , true

        $scope.$watch ->
            SharesService.shares
        , (new_shares, old_shares) ->
            if new_shares.length isnt old_shares.length
                if $location.path() isnt "/share"
                    $scope.sharesNotification++
        , true

        $scope.$watch ->
            $location.path()
        , (path) ->
            if path is "/users" or path is "/room"
                $scope.usersNotification = 0
            if path is "/share"
                $scope.sharesNotification = 0
        , true

        $scope.leaveRoom = ->
            RTCService.sendUserDeleted( UserService.getUser($rootScope.userId) )
            UserService.delete()
            $rootScope.userId = undefined
            $rootScope.roomId = undefined

            window.location = "/"
        $scope.IntroOptions =
          steps: [
            {
              element: "#step1"
              intro: "This is the main Menu. <br>Hover to show the tooltips."
              position: "right"
            }
            {
              element: "#step2"
              intro: "Create a room if you want to share something."
              position: "left"
            }
          ]
          showStepNumbers: false
          exitOnOverlayClick: true
          exitOnEsc: true
          nextLabel: "<span style=\"color:green\">Next</span>"
          prevLabel: "<span style=\"color:green\">Previous</span>"
          skipLabel: "Exit"
          doneLabel: "Thanks"
        ]
