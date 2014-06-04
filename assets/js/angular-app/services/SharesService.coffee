# Unwatched - Shares Service
# ============================

"use strict"

app = angular.module "unwatched.services"

class Shares
    @::shares = []
    class Item
        @::id = 0
        @::name = ""
        @::size = 0
        @::author = ""
        @::created = undefined
        @::uploaded = undefined
        @::last_edited = undefined
        @::category = ""
        @::thumbnail = []
        @::content = ""
        @::path = ""
        @::extension = ""
        @::templateUrl = ""
        @::contributors = undefined
        @::deltas = undefined
        constructor: (@id, @name, @author, @category) ->
            if @category isnt "image"
                @templateUrl = "/partials/items/thumbnails/" +
                    category + ".html"
            else
                @templateUrl = "/partials/items/thumbnails/file.html"
            @size = 0

            if @category is "file" and @category is "image"
                @uploaded = new Date()
            @created = new Date()

            if @category is "code" or @category is "note"
                @contributors = []
                @contributors.push
                    id: @author
                    active: true

            @extension = ""

        setName: (@name) ->

        setSize: (@size) ->

        setThumbnail: (@thumbnail) ->

        setContent: (content) ->
            @content = content
            if @category isnt "code" and @category isnt "note"
                return
            @last_edited = new Date()

        setPath: (@path) ->

        setExtension: (@extension) ->

        setCreated: (@created) ->


    constructor: (@$rootScope) ->

    getItemIndex: (item_id) =>
        item = {}
        for i of @shares
            item = @shares[i]
            if item.id is parseInt(item_id)
                return i

    getFirstFreeId: =>
        ids = []
        freeId = 0
        for i of @shares
            ids.push @shares[i].id

        while true
            if ids.indexOf(freeId) isnt -1
                freeId++
            else
                return freeId

        return freeId

    getItems: ->
        @shares

    get: (id) ->
        @shares[ @getItemIndex(id) ]

    delete: (id) ->
        console.log "delete: ", id
        item = @get id

        return if !item

        if item.category is "screen" or item.category is "webcam"
            item.content.stop?()
            item.content = "" if item.content isnt ""

        @shares.splice( @getItemIndex(id), 1 )

        @$rootScope.$apply() if !@$rootScope.$$phase


    create: (author, category) ->
        id = @getFirstFreeId()
        name = "Untitled " + category
        @shares.push new Item( id, name, author, category )
        return id

    updateItem: (itemId, change) ->
        console.log "updateItem with id: " + itemId, change
        item = @get(itemId)
        console.log "item", item
        changeKeys = Object.keys(change)

        for changeKey of changeKeys
            item[changeKeys[changeKey]] = change[changeKeys[changeKey]]
            console.log "changing " + changeKeys[changeKey] + " to:",
                change[changeKeys[changeKey]]



    getContributor: (itemId, contributorId) ->
        item = @get(itemId)

        for contributor in item.contributors
            if contributor.id is contributorId
                return contributor

        return false

    setContributorInactive: (itemId, contributorId) ->
        item = @get(itemId)

        for contributor in item.contributors
            if contributor.id is contributorId
                contributor.active = false

app.service "SharesService", ["$rootScope", Shares ]
