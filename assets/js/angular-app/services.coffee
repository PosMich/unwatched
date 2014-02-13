# Unwatched - Angular Services
# ============================

"use strict"

class RTCProvider
  constructor: ->
    console.log "BLAAAA!"
    @.name = "asdf"
  setName: (name) ->
    console.log "blubb"
    @.name = name
  $get: ->
    logName: =>
      console.log "Hello " + @.name
    setName: (name) =>
      @.name = name


app = angular.module "unwatched.services", []
app.provider "RTC", RTCProvider
app.value "version", "0.1"
