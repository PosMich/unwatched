# Unwatched - Stream Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

app.directive "screen", [
    "StreamService"
    (StreamService) ->

        link: (scope, element, attrs) ->
            navigator.getUserMedia =
                navigator.webkitGetUserMedia ||
                navigator.mozGetUserMedia ||
                navigator.getUserMedia

            successCallback = (stream) ->
                StreamService.setScreenStream(stream)
                StreamService.setScreenVideo(angular.element("video#screen")[0])
                StreamService.startScreenVideo()

            errorCallback = (error) ->
                console.log('Failed.', error)

            requestUserMedia = ->

                maxWidth = 1280
                maxHeight = 720

                userMediaOptions = {
                    audio: false
                    video: {
                        mandatory: {
                            chromeMediaSource: 'screen'
                            maxWidth: maxWidth
                            maxHeight: maxHeight
                        }
                    }
                }

                if navigator.getUserMedia?
                    navigator.getUserMedia(userMediaOptions,
                        successCallback, errorCallback)

            element.on "click", ->
                requestUserMedia()

]

app.directive "webcam", [
    "StreamService"
    (StreamService) ->

        link: (scope, element, attrs) ->

            navigator.getUserMedia =
                navigator.webkitGetUserMedia ||
                navigator.mozGetUserMedia ||
                navigator.getUserMedia

            successCallback = (stream) ->
                StreamService.setWebcamStream(stream)
                StreamService.setWebcamVideo(angular.element("video#webcam")[0])
                StreamService.startWebcamVideo()

            errorCallback = (error) ->
                console.log('Failed.', error)

            requestUserMedia = ->

                maxWidth = 1280
                maxHeight = 720

                userMediaOptions = {
                    audio: false
                    video: true
                }

                if navigator.getUserMedia?
                    navigator.getUserMedia(userMediaOptions,
                        successCallback, errorCallback)

            element.on "click", ->
                requestUserMedia()

]
