# Unwatched - File Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "FileCtrl", [
    "$scope", "$routeParams", "SharesService", "$location", "$modal",
    "UserService", "$rootScope", "RTCService", "FileService"
    ($scope, $routeParams, SharesService, $location, $modal, UserService,
        $rootScope, RTCService, FileService) ->

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

                FileService.saveFile(
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


            # $scope.$watch ->
            #     $scope.file.ready
            # , (ready) ->
            #     console.log "readystate: " + ready
            #     if ready is true
            #         $scope.item.content = $scope.target_result

                    # console.log "content", $scope.item.content
                    # console.log "target result", $scope.target_result

                    # if $scope.item.category is "image"
                    #     img = document.createElement("img")
                    #     canvas = document.createElement("canvas")
                    #     reader = new FileReader()

                    #     img.src = $scope.target_result
                    #     img.onload = ->

                    #         max_width = 300
                    #         width = img.width
                    #         height = img.height

                    #         if width > max_width
                    #             height *= max_width / width
                    #             width = max_width

                    #         canvas.width = width
                    #         canvas.height = height

                    #         ctx = canvas.getContext "2d"
                    #         ctx.drawImage( img, 0, 0, width, height )

                    #         $scope.item.thumbnail = canvas.toDataURL(
                    #             $scope.item.mime_type
                    #         )

                    #         $scope.$apply() if !$scope.$$phase
            # , true

        else
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?
            $scope.newFile = false

            FileService.fileExists( $scope.item.id, (exists) ->
                if !exists
                    RTCService.requestItem $scope.item.id
                    console.log "request file"
            )

            $scope.$watch ->
                $scope.item.name
            , (name) ->
                fileMessage =
                    name: name
                RTCService.sendFileHasChanged(fileMessage, $scope.item.id,
                    $scope.user)
            , true


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
