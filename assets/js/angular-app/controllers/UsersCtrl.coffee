# Unwatched - User Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "UsersCtrl", [
    "$scope", "ChatStateService", "LayoutService", "RoomService", "UserService"
    ($scope, ChatStateService, LayoutService, RoomService, UserService) ->

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
