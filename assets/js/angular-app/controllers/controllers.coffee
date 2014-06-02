# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "AppCtrl", [
    "$scope", "$rootScope", "SharesService", "StreamService", "ChatService",
    "RoomService"
    ($scope, $rootScope, SharesService, StreamService, ChatService,
        RoomService) ->

        $scope.isClosed = false

        # init stream
        $rootScope.isStreaming =
            webcam: false
            screen: false

        $rootScope.streamId =
            webcam: -1
            screen: -1

        $rootScope.disableStream =
            webcam: false
            screen: false

        $rootScope.screenshotCountdown = -1

        $scope.killStream = (type) ->
            if type is 'screen'
                StreamService.killScreenStream()
            else
                StreamService.killWebcamStream()

        $scope.$watch ->
            RoomService.isClosed
        , (isClosed) ->
            if isClosed
                $scope.isClosed = isClosed
                window.setTimeout((->
                    window.location = "/"
                ), 5000)

]

app.controller "DeleteModalInstanceCtrl", [
    "$scope", "$modalInstance", "item", "UserService"
    ($scope, $modalInstance, item, UserService) ->
        $scope.item = item
        $scope.users = UserService.users

        $scope.ok = ->
            $modalInstance.close()

        $scope.cancel = ->
            $modalInstance.dismiss('cancel')

]

# app.controller "ImageCtrl", [
#     "$scope", "$routeParams", "SharesService", "$location", "$filter",
#     "$modal"
#     ($scope, $routeParams, SharesService, $location, $filter
#         $modal) ->
#
#         $scope.item = {}
#
#         if !$routeParams.id?
#             # create new image item
#             $scope.item = SharesService.create("image", $rootScope.userId)
#             $scope.image_error = ""
#             $scope.item.mime_type = ""
#
#             # thumbnail processing
#             img = document.createElement("img")
#             canvas = document.createElement("canvas")
#
#             $scope.onFileSelect = ($files) ->
#                 file = $files[0]
#
#                 if !(/image\/(gif|jpeg|png)$/i).test(file.type.toString())
#                     $scope.image_error = "The file you have coosen has a " +
#                         "wrong MIME-Type (it has: " + file.type.toString() +
#                         "). Please try it again with an image."
#                     return
#                 $scope.image_error = ""
#
#                 $scope.item.size = file.size
#                 $scope.item.created = $filter("date")(file.lastModifiedDate,
#                     "dd.MM.yyyy H:mm")
#                 $scope.item.uploaded = $filter("date")(new Date(),
#                     "dd.MM.yyyy H:mm")
#                 $scope.item.name = file.name
#                 $scope.item_name = file.name
#                 $scope.item.mime_type = file.type
#
#                 # read file
#                 reader = new FileReader()
#
#                 reader.onload = (e) ->
#                     $scope.item.path = e.target.result
#                     img.src = e.target.result
#
#                     img.onload = ->
#
#                         max_width = 300
#                         width = img.width
#                         height = img.height
#
#                         if width > max_width
#                             height *= max_width / width
#                             width = max_width
#
#                         canvas.width = width
#                         canvas.height = height
#
#                         ctx = canvas.getContext "2d"
#                         ctx.drawImage( img, 0, 0, width, height )
#
#                         $scope.item.thumbnail = canvas.toDataURL(
#                             $scope.item.mime_type
#                         )
#
#                     $scope.$apply()
#
#                 reader.readAsDataURL file
#
#
#
#         else
#             $scope.item = SharesService.get($routeParams.id)
#             $location.path "/404" if !$scope.item?
#
#         # for inline editing
#         $scope.disabled = true
#
#         $scope.item_name = $scope.item.name
#
#
#         $scope.delete = ->
#             modalInstance = $modal.open(
#                 templateUrl: "/partials/deleteModal.html"
#                 controller: "DeleteModalInstanceCtrl"
#                 size: "lg"
#                 resolve: {
#                     item: ->
#                         $scope.item
#                 }
#             )
#
#             modalInstance.result.then( ->
#                 SharesService.delete($scope.item.id)
#                 $location.path("/share")
#             )
# ]
#
# app.controller "ScreenshotCtrl", [
#     "$scope", "$routeParams", "SharesService", "$modal", "$location"
#     ($scope, $routeParams, SharesService, $modal, $location) ->
#
#         $scope.item = {}
#
#         if $routeParams.id?
#             $scope.item = SharesService.get $routeParams.id
#             $location.path "/404" if !$scope.item?
#         else
#             console.log "take new screenshot"
#
#
#         $scope.delete = ->
#             modalInstance = $modal.open(
#                 templateUrl: "/partials/deleteModal.html"
#                 controller: "DeleteModalInstanceCtrl"
#                 size: "lg"
#                 resolve: {
#                     item: ->
#                         $scope.item
#                 }
#             )
#
#             modalInstance.result.then( ->
#                 SharesService.delete $scope.item.id
#                 $location.path "/share"
#             )
#
# ]
