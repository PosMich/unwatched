# Unwatched - Angular Services
# ============================

"use strict"




app = angular.module "unwatched.services", []

app.provider "RTC", RTCProvider

app.value "version", "0.1"

app.service "ChatStateService", ->

    @chat_state = "compressed"
    @chat_state_history = ""

    @setChatState = (chat_state) ->
        @chat_state = chat_state

    @setChatStateHistory = (chat_state_history) ->
        @chat_state_history = chat_state_history

    return
