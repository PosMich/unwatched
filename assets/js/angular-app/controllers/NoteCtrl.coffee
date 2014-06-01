# Unwatched - Note Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "NoteCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "$filter"
    ($scope, $routeParams, SharesService, $location, $modal
        $filter) ->

        $scope.item = {}

        if !$routeParams.id?
            # create new note item
            # $scope.item = SharesService.create($rootScope.userId, "note")
            $scope.item = SharesService.get SharesService.create(0, "note")

        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

        $scope.text = $scope.item.content

        # tinymce options
        $scope.tinymceOptions = {
            resize: "both"
            height: 400
            handle_event_callback: (e) ->
                console.log e
            onchange_callback: (e) ->
                console.log e
            setup: (editor) ->
                editor.on "change", (e) ->
                    console.log e
                    col = e.level.bookmark.start[0]
                    row = e.level.bookmark.start[2]
        }

        # for inline editing
        $scope.disabled = true
        $scope.item_name = $scope.item.name

        $scope.$watch ->
            $scope.item.name
        , (value) ->
            $scope.item.thumbnail.title = $scope.item.name

        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                SharesService.delete $scope.item.id
                $location.path "/share"
            )

]
