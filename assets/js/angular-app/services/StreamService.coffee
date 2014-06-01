# Unwatched - Stream Service
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "StreamService", [
    "$rootScope", "SharesService"
    ($rootScope, SharesService) ->

        @screenStream = undefined
        @screenVideo = undefined
        @screen_item_id = undefined
        @webcamStream = undefined
        @webcamVideo = undefined
        @webcam_item_id = undefined

        @setScreenStream = (stream) ->
            @screenStream = stream
            @screenStream.onended = @killScreenStream

        @setWebcamStream = (stream) ->
            @webcamStream = stream
            @webcamStream.onended = @killWebcamStream

        @setScreenVideo = (video) ->
            @screenVideo = video

        @setWebcamVideo = (video) ->
            @webcamVideo = video

        @setScreenItemId = (item_id) ->
            @screen_item_id = item_id

        @setWebcamItemId = (item_id) ->
            @webcam_item_id = item_id

        @startScreenVideo = ->
            @screenVideo.src = window.URL.createObjectURL @screenStream
            @screenVideo.play()
            $rootScope.video.show.screen = true
            $rootScope.$apply()

        @startWebcamVideo = ->
            @webcamVideo.src = window.URL.createObjectURL @webcamStream
            @webcamVideo.play()
            $rootScope.video.show.webcam = true
            $rootScope.$apply()

        @killScreenStream = =>
            $rootScope.video.show.screen = false
            window.setTimeout((=>
                @screenVideo.pause()
                @screenVideo.src = null
                if @screenStream?
                    @screenStream.stop()
                    @screenStream = undefined
                    SharesService.delete(@screen_item_id)

                $rootScope.$apply()  if !$rootScope.$$phase
            ), 500)

        @killWebcamStream = =>
            $rootScope.video.show.webcam = false
            window.setTimeout((=>
                @webcamVideo.pause()
                @webcamVideo.src = null
                if @webcamStream?
                    @webcamStream.stop()
                    @webcamStream = undefined
                    SharesService.delete(@webcam_item_id)

                $rootScope.$apply()  if !$rootScope.$$phase
            ), 500)

        return

]
