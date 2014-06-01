# Unwatched - Chat Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "ChatCtrl", [
    "$scope", "$rootScope", "ChatStateService", "ChatService", "UserService"
    ($scope, $rootScope, ChatStateService, ChatService, UserService) ->
        window.chat = ChatService
        $scope.chat = {}
        $scope.chat.state = ChatStateService.chat_state
        $scope.chat.state_history = ChatStateService.chat_state_history

        $scope.users = UserService.users
        $scope.chat.messages = ChatService.messages
        $scope.userId = $rootScope.userId
        $scope.chatNotifications = 0

        $scope.$watch ->
            $scope.chat.messages
        , (new_messages, old_messages) ->
            if new_messages.length > old_messages.length
                if $scope.chat.state is "minimized"
                    $scope.chatNotifications++
        , true

        $scope.$watch ->
            $scope.chat.state
        , (new_state, old_state) ->
            if old_state is "minimized" and new_state isnt "minimized"
                $scope.chatNotifications = 0
        , true

        $scope.submitChatMessage = ->
            ChatService.addMessage $scope.chat.message
            $scope.chat.message = ""

        $scope.chat.compress = ->
            $scope.chat.state = "compressed"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.expand = ->
            $scope.chat.state = "expanded"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.minimize = ->
            $scope.chat.state_history = $scope.chat.state
            ChatStateService.setChatStateHistory($scope.chat.state_history)
            $scope.chat.state = "minimized"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.maximize = ->
            if $scope.chat.state is "minimized"
                $scope.chat.state = $scope.chat.state_history
                ChatStateService.setChatState($scope.chat.state_history)

]
