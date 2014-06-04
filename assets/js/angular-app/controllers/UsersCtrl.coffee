# Unwatched - User Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "UsersCtrl", [
    "$scope"
    "ChatStateService"
    "LayoutService"
    "RoomService"
    "UserService"
    "SharesService"
    "$rootScope"
    ($scope, ChatStateService, LayoutService, RoomService, UserService,
        SharesService, $rootScope) ->

        $scope.isInRoom = RoomService.id isnt ""
        if !$scope.isInRoom
            return

        $scope.users = UserService.users

        $scope.$watch ->
            ChatStateService.chat_state
        , (new_state, old_state) ->
            $scope.chat_state = new_state
        , true

        $scope.$watch (->
            LayoutService.layout
        ), ((layout) ->
            $scope.controls.layout = layout
        ), true

        $scope.$watch ->
            SharesService.shares
        , (shares) ->
            #console.log "shares should update user"
            for user in $scope.users
                foundWebcam = false
                foundScreen = false
                for share in shares
                    #console.log "share author " + share.author + " user id " + user.id
                    if share.author is user.id
                        #console.log "share category " + share.category
                        if share.category is "webcam"
                            user.webcam = share.id
                            $scope.$apply() if !$scope.$$phase
                            foundWebcam = true
                        else if share.category is "screen"
                            user.screen = share.id
                            $scope.$apply() if !$scope.$$phase
                            foundScreen = true
                user.screen = -1 if !foundScreen
                user.webcam = -1 if !foundWebcam
        , true

        $scope.controls = {}
        $scope.controls.sorting = {}
        $scope.controls.sorting.state = ""
        $scope.controls.sorting.ascending = false
        $scope.controls.layout = LayoutService.layout

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                # reset sorting
                if $scope.controls.sorting.ascending
                    $scope.controls.sorting.state = ""
                # switch sorting direction descending/ascending
                $scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

        $scope.setLayout = (layout) ->
            LayoutService.setLayout(layout)

]
