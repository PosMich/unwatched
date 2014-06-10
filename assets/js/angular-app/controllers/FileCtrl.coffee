# Unwatched - File Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "FileCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "UserService", "$rootScope", "RTCService", "FileApiService"
    ($scope, $routeParams, SharesService, $location, $modal, UserService,
        $rootScope, RTCService, FileApiService) ->

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?
            $scope.newFile = true

            $scope.item =
                size: 0
                name: "New file"
                progress: -1

            $scope.file = {}

            $scope.onFileSelect = ($files) ->
                # create new image item
                sharedItemId = SharesService.create( $rootScope.userId, "file" )
                $scope.item = SharesService.get( sharedItemId )

                RTCService.sendNewFile( $scope.item,
                    $scope.user.isMaster )

                $scope.item.mime_type = ""

                $scope.file.source = $files[0]

                $scope.item.name = $scope.file.source.name
                $scope.item.originalName = $scope.file.source.name
                $scope.item.mime_type = $scope.file.source.type
                $scope.item.size = $scope.file.source.size
                $scope.item.created = $scope.file.source.lastModifiedDate
                $scope.item.uploaded = new Date()

                if (/image\/(gif|jpeg|png)$/i).test($scope.file.source.type.toString())
                    $scope.item.category = "image"

                FileApiService.saveFile(
                    $scope.item.id
                    $scope.file.source
                    (success) ->
                        if success
                            # send changes
                            changes =
                                name: $scope.item.name
                                originalName: $scope.item.originalName
                                mime_type: $scope.item.mime_type
                                size: $scope.item.size
                                created: $scope.item.created
                                uploaded: $scope.item.uploaded
                                category: $scope.item.category

                            RTCService.sendFileHasChanged(
                                changes
                                $scope.item.id
                                $scope.user
                            )
                        else
                            $location.path "/shares"
                            $rootScope.$apply() if $rootScope.$$phase
                )

            $scope.$watch ->
                $scope.item.thumbnail
            , (thumbnail) ->
                if thumbnail? and thumbnail isnt ""
                    message =
                        thumbnail: thumbnail

                    RTCService.sendFileHasChanged(message, $scope.item.id,
                        $scope.user)
            , true

        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?
            $scope.newFile = false

            FileApiService.fileExists( $scope.item.id, (exists) ->
                if !exists
                    RTCService.requestItem $scope.item.id
                else
                    FileApiService.setURL $scope.item.id
            )

            $scope.$watch ->
                $scope.item.name
            , (name) ->
                fileMessage =
                    name: name
                RTCService.sendFileHasChanged(fileMessage, $scope.item.id,
                    $scope.user)
            , true

        $scope.uploadFile = ->
            #console.log "blubb"
            make =
                upload: do -> angular.element(".file-select").first().click()


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
                RTCService.sendItemDeleted( $scope.user, $scope.item.id )
                SharesService.delete $scope.item.id
                $location.path "/share"
            )
]
