#https://code.google.com/p/webrtc/source/browse/stable/samples/js/base/adapter.js

trace = (text) ->
    # This function is used for logging.
    text = text.substring(0, text.length - 1)  if text[text.length - 1] is "\n"
    console.log (performance.now() / 1000).toFixed(3) + ": " + text
    return

RTCPeerConnection = null
getUserMedia = null
attachMediaStream = null
reattachMediaStream = null
webrtcDetectedBrowser = null
webrtcDetectedVersion = null
isWebrtcAble = false

if navigator.mozGetUserMedia
    isWebrtcAble = true
    console.log "This appears to be Firefox"
    webrtcDetectedBrowser = "firefox"
    webrtcDetectedVersion = parseInt(
        navigator.userAgent.match(/Firefox\/([0-9]+)\./)[1]
        , 10
    )

    # The RTCPeerConnection object.
    RTCPeerConnection = mozRTCPeerConnection

    # The RTCSessionDescription object.
    RTCSessionDescription = mozRTCSessionDescription

    # The RTCIceCandidate object.
    RTCIceCandidate = mozRTCIceCandidate

    # Get UserMedia (only difference is the prefix).
    # Code from Adam Barth.
    getUserMedia = navigator.mozGetUserMedia.bind(navigator)

    # Creates iceServer from the url for FF.
    createIceServer = (url, username, password) ->
        iceServer = null
        url_parts = url.split(":")
        if url_parts[0].indexOf("stun") is 0

            # Create iceServer with stun url.
            iceServer = url: url
        else if url_parts[0].indexOf("turn") is 0
            if webrtcDetectedVersion < 27

                # Create iceServer with turn url.
                # Ignore the transport parameter from TURN url for FF
                # version <=27.
                turn_url_parts = url.split("?")

                # Return null for createIceServer if transport=tcp.
                if turn_url_parts[1].indexOf("transport=udp") is 0
                    iceServer =
                        url: turn_url_parts[0]
                        credential: password
                        username: username
            else

                # FF 27 and above supports transport parameters in TURN url,
                # So passing in the full url to create iceServer.
                iceServer =
                    url: url
                    credential: password
                    username: username
        iceServer


    # Attach a media stream to an element.
    attachMediaStream = (element, stream) ->
        console.log "Attaching media stream"
        element.mozSrcObject = stream
        element.play()
        return

    reattachMediaStream = (to, from) ->
        console.log "Reattaching media stream"
        to.mozSrcObject = from.mozSrcObject
        to.play()
        return


    # Fake get{Video,Audio}Tracks
    unless MediaStream::getVideoTracks
        MediaStream::getVideoTracks = ->
            []
    unless MediaStream::getAudioTracks
        MediaStream::getAudioTracks = ->
            []

else if navigator.webkitGetUserMedia
    isWebrtcAble = true
    console.log "This appears to be Chrome"
    webrtcDetectedBrowser = "chrome"
    webrtcDetectedVersion = parseInt(
        navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./)[2]
        , 10
    )

    # Creates iceServer from the url for Chrome.
    createIceServer = (url, username, password) ->
        iceServer = null
        url_parts = url.split(":")
        if url_parts[0].indexOf("stun") is 0

            # Create iceServer with stun url.
            iceServer = url: url
        else if url_parts[0].indexOf("turn") is 0

            # Chrome M28 & above uses below TURN format.
            iceServer =
                url: url
                credential: password
                username: username
        iceServer


    # The RTCPeerConnection object.
    RTCPeerConnection = webkitRTCPeerConnection

    # Get UserMedia (only difference is the prefix).
    # Code from Adam Barth.
    getUserMedia = navigator.webkitGetUserMedia.bind(navigator)

    # Attach a media stream to an element.
    attachMediaStream = (element, stream) ->
        if typeof element.srcObject isnt "undefined"
            element.srcObject = stream
        else if typeof element.mozSrcObject isnt "undefined"
            element.mozSrcObject = stream
        else if typeof element.src isnt "undefined"
            element.src = URL.createObjectURL(stream)
        else
            console.log "Error attaching stream to element."
        return

    reattachMediaStream = (to, from) ->
        to.src = from.src
        return
else
    console.log "Browser does not appear to be WebRTC-capable"


window.RTCPeerConnection = RTCPeerConnection
window.getUserMedia = getUserMedia
window.attachMediaStream = attachMediaStream
window.reattachMediaStream = reattachMediaStream
window.webrtcDetectedBrowser = webrtcDetectedBrowser
window.webrtcDetectedVersion = webrtcDetectedVersion
window.isWebrtcAble = isWebrtcAble