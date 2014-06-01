# Unwatched - Share Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "ShareCtrl", [
    "$scope", "ChatStateService", "SharesService", "LayoutService", "$modal",
    "StreamService", "UserService", "$rootScope", "RTCService"
    ($scope, ChatStateService, SharesService, LayoutService, $modal,
        StreamService, UserService, $rootScope, RTCService) ->

        $scope.shared_items = SharesService.getItems()
        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        $scope.$watch (->
            return ChatStateService.chat_state
        ), ((new_state, old_state) ->
            $scope.chat_state = new_state
        ), true

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

        $scope.delete = (item_id) ->

            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        SharesService.get(item_id)
                }
            )

            modalInstance.result.then( ->
                category = SharesService.get(item_id).category
                if category is "screen"
                    StreamService.killScreenStream(category)
                else if category is "webcam"
                    StreamService.killWebcamStream(category)
                else
                    SharesService.delete(item_id)

                RTCService.sendCodeItemDeleted($scope.user, item_id)
            )

        $scope.setLayout = (layout) ->
            LayoutService.setLayout(layout)

]
