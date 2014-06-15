# Unwatched - Download Directive
# ==============================

"use strict"

app = angular.module "unwatched.directives"

class DownloadDirective
    @$inject: ['$window']
    constructor: (window) ->
        @URL = window.webkitURL or window.URL
        @Blob = window.Blob

    restrict: 'A'

    link: (scope, element, attrs) =>
        a = element[0]

        if a.draggable
            element.bind "dragstart", (event) ->
                event.originalEvent.dataTransfer.setData "DownloadURL",
                    a.dataset.downloadurl

        a.href = '#'
        element.click -> no if a.href == '#'

        attrNames = ['ngDownload', 'mimeType', 'url', 'content']

        updateDom = =>
            [filename, mimeType, url, content] =
                (scope.$eval attrs[attr] for attr in attrNames)
            filename or= 'file'
            mimeType or= 'text/plain'

            if url?
                @setupUrlDownload a, url, filename, mimeType
            else if content?
                @setupDataDownload a, content, filename, mimeType

        watchers = {}
        for attr in attrNames
            do (attr) ->
                attrs.$observe attr, (attrValue) ->
                    watchers[attr]() if watchers[attr]?
                    if attrValue
                        watchers[attr] = scope.$watch attrValue, updateDom

    setupUrlDownload: (a, url, filename, mimeType) =>
        @URL.revokeObjectURL a.href if a.href != '#'
        a.download = filename
        a.href = url
        a.dataset.downloadurl = [mimeType, a.download, a.href].join(":")

    setupDataDownload: (a, data, filename, mimeType) =>
        blob = new @Blob [data], type: mimeType
        url = @URL.createObjectURL blob
        @setupUrlDownload a, url, filename, mimeType

buildDirectiveFactory = (ctor) ->
    factory = (args...) -> new ctor args...
    factory.$inject = ctor.$inject
    factory

app.directive 'ngDownload', buildDirectiveFactory DownloadDirective
