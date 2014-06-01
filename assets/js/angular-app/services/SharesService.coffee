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
            @templateUrl = "/partials/items/thumbnails/" +
                category + ".html"
            @size = 0

            if @category isnt "file" and @category isnt "image"
                @created = new Date()
            else
                @uploaded = new Date()

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
        @shares.splice( @getItemIndex(id), 1 )


    create: (author, category) ->
        id = @getFirstFreeId()
        name = "Untitled " + category
        @shares.push new Item( id, name, author, category )
        return id

    updateItem: (itemId, change) ->
        item = @get(itemId)
        changeKeys = Object.keys(change)

        for changeKey of changeKeys
            item[changeKeys[changeKey]] = change[changeKeys[changeKey]]

        # @$rootScope.$apply() if !@$rootScope.$$phase

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
