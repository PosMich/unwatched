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
                RTCService.sendItemDeleted($scope.user, item_id)
                category = SharesService.get(item_id).category
                if category is "screen" or category is "webcam"
                    $scope.deleteStream item_id
                else
                    SharesService.delete(item_id)

            )

        $scope.setLayout = (layout) ->
            LayoutService.setLayout(layout)

        $scope.deleteStream = (itemId) ->

            item = SharesService.get itemId

            id = item.id
            category = item.category

            RTCService.sendItemDeleted( $scope.user, id )

            SharesService.delete id

            $rootScope.isStreaming[category] = false
            $rootScope.streamId[category] = -1

            angular.element("#" + category).src = null


            $rootScope.$apply() if !$rootScope.$$phase

]
