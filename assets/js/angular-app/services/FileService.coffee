# Unwatched - RTC Service
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "FileService", [
    "$rootScope"
    "RoomService"
    "SharesService"
    "$location"
    "$timeout"
    ($rootScope, RoomService, SharesService, $location, $timeout) ->

        console.log "file"

        @fileSystem = undefined
        @root = undefined
        @roomDir = undefined
        # id: 123, chunks: []
        @chunkBlocks = {}

        @initFs = ->
            window.requestFileSystem = window.requestFileSystem ||
                window.webkitRequestFileSystem

            navigator.webkitPersistentStorage.requestQuota(
                1024 * 1024 * 1024 * 5
                (grantedBytes) =>
                    window.requestFileSystem(
                        window.PERSISTENT
                        grantedBytes
                        @onInitFs
                        @onErrorFs
                    )
                (e) ->
                    console.log 'Error', e
            )

        @onInitFs = (fs) =>
            console.log "created file-system " + fs.name + ":"
            console.log fs
            @fileSystem = fs
            @root = @fileSystem.root
            @root.getDirectory(
                RoomService.id.toString()
                { create: true }
                (dir) =>
                    @roomDir = dir
                (error) ->
                    console.log "error on dir create", error
            )

        @onErrorFs = (error) ->
            if error.code is FileError.QUOTA_EXCEEDED_ERR
                console.log "quota exceeded"


        @createDirectory = (baseDir, name, callback) ->
            baseDir.getDirectory(
                name
                { create: true }
                (dir) ->
                    console.log "successfully created directory '" + baseDir +
                        "/" + name + "'"
                    callback(dir)
                (error) ->
                    console.log "failed to created directory", error
                    callback(false)
            )
        # write every 1000 junks
        @initChunkFile = (id, callback) ->
            ##@chunkBlocks[id] =
            #    index: 0
            #    blocks: [[],[]]

            console.log "init chunk file", @chunkBlocks

            @createDirectory(
                @roomDir
                id.toString()
                (dir) =>
                    if !dir
                        callback(false)
                        return
                    console.log "created file"
                    @createFile(
                        dir
                        SharesService.get(id).originalName
                        (fileEntry) =>
                            console.log "got fileentry"
                            if !fileEntry
                                callback(false)
                                return
                            console.log "created fileEntry", fileEntry
                            callback(true)
                    )
            )
        @createFile = (baseDir, name, callback) ->
            baseDir.getFile(
                name
                { create: true }
                (fileEntry) ->
                    console.log "successfully created fileEntry '" + baseDir +
                        "/" + name + "'"
                    callback(fileEntry)
                (error) ->
                    console.log "failed to created directory", error
                    callback(false)
            )

        @saveFile = (id, file, callback) ->

            reader = new FileReader()
            item = SharesService.get(id)

            name = item.originalName
            size = item.size

            console.log "item size " + size
            console.log "file size " + file.size

            updateProgress = (currentSize) ->

                item.progress = Math.round( currentSize / size * 100 )

                if item.progress >= 100
                    item.progress = 100

                $rootScope.$apply() if !$rootScope.$$phase

            writer = (fileEntry) =>
                console.log "WRITER :: fileEntry", fileEntry
                fileEntry.createWriter(
                    (fileWriter) =>

                        CHUNK_SIZE = 1024 * 1024 * 5
                        i = 0
                        start = i * CHUNK_SIZE

                        console.log "trying to write data"

                        reader.readAsArrayBuffer file.slice( start,
                            start + CHUNK_SIZE )

                        reader.onload = (e) ->

                            fileWriter.seek( fileWriter.length )
                            fileWriter.write(new Blob(
                                [e.target.result]
                            ))

                        fileWriter.onwritestart = (e) ->
                            console.log "started writing", e

                        fileWriter.onwriteend = (e) =>
                            console.log "finished writing, next " +
                                "step = " + (i * CHUNK_SIZE)
                            i++
                            start = i * CHUNK_SIZE

                            updateProgress(start)

                            if start < file.size
                                if (start+CHUNK_SIZE) > file.size
                                    reader.readAsArrayBuffer file.slice(
                                        start, file.size
                                    )
                                else
                                    reader.readAsArrayBuffer file.slice(
                                        start, start + CHUNK_SIZE )
                            else
                                console.log "finished writing 100% :D"
                                @setURL(id)

                                $timeout(
                                    ->
                                        $location.path "/share/file/" + id
                                        $rootScope.$apply() if !$rootScope.$$phase
                                    1000
                                )
                                callback(true)

                        fileWriter.onerror = (error) ->
                            console.log "filewriter error", error
                            console.log "error was" + fileWriter.error.message
                            callback(false)

                    (error) ->
                        console.log "error on create writer", error
                        callback(false)
                )

            @createDirectory(
                @roomDir
                id.toString()
                (dir) =>
                    if !dir
                        callback(false)
                        return
                    @createFile(
                        dir
                        name
                        (fileEntry) =>
                            if !fileEntry
                                callback(false)
                                return
                            console.log "created fileEntry", fileEntry
                            writer(fileEntry)

                    )
            )

        @setURL = (id) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            @root.getFile(
                filename
                {}
                (file) ->
                    item.content = file.toURL()
                    console.log "changed item content to url: " + item.content
            )

        @deleteFile = (id) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            @root.getFile(
                filename
                { create: false }
                (file) ->
                    file.remove(
                        ->
                            console.log "file successfully removed"
                        (error) ->
                            console.log "error on file remove", error
                    )
                (error) ->
                    console.log "was not able to get file due:", error
            )

        @fileExists = (id, callback) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            @root.getFile(
                filename
                { create: false }
                (file) ->
                    callback true
                    console.log "get file success", file
                ->
                    callback false
                    console.log "get file error"
            )


        @ab2ascii = (buf) ->
            String.fromCharCode.apply(null, buf).trim()

        @ascii2ab = (str) ->
            buf = new Uint8Array(str.length)
            i = 0

            while i < buf.length
                buf[i] = str.charCodeAt i
                ++i

            return buf


        @chunks = []

        @getAbChunks = (id, callback, finishedCallback) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName


            CHUNK_SIZE = 800
            i = 0
            start = i * CHUNK_SIZE

            @root.getFile(
                filename
                {}
                (fileEntry) =>
                    fileEntry.file(
                        (file) =>
                            reader = new FileReader()
                            reader.onload = (evt) =>
                                if evt.target.readyState is FileReader.DONE
                                    callback @ab2ascii(new Uint8Array(evt.target.result))


                                i = i + 1
                                start = i * CHUNK_SIZE

                                if start > file.size
                                    console.log "finished", i
                                    finishedCallback()
                                    return

                                if (start+CHUNK_SIZE) < file.size
                                    reader.readAsArrayBuffer file.slice(
                                        start
                                        start + CHUNK_SIZE
                                    )
                                else
                                    console.log "read last bits"
                                    console.log "start", start
                                    console.log "file.size", file.size
                                    reader.readAsArrayBuffer file.slice(
                                        start
                                        file.size
                                    )

                            reader.readAsArrayBuffer file.slice(
                                    start
                                    start + CHUNK_SIZE
                                )

                         (error) ->
                             console.log "FileService error", error
                    )
            )



        @addChunk = (id, chunk) =>
            @chunks.push @ascii2ab(chunk)

        @writeChunks = (id) =>
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            #data = new Blob( @chunks )

            data = @chunks

            console.log "chunks.length", @chunks.length



            #@chunks = []

            console.log "data", data
            index = 0
            @root.getFile(
                filename
                {}
                (fileEntry) =>
                    fileEntry.createWriter(
                        (fileWriter) =>
                            fileWriter.onwritestart = (e) ->
                                console.log "write Block"
                            fileWriter.onwriteend = (e) =>
                                console.log "write end"
                                #console.log fileWriter
                                console.log "length is", fileWriter.length
                            fileWriter.onerror = (error) ->
                                console.log "filewriter error", error
                                console.log "error was" + fileWriter.error.message

                            fileWriter.write new Blob( data )
                            console.log fileWriter
                            console.log "length is", fileWriter.length


                        (error) ->
                             console.log "FileService error", error
                    )
            )


        @fileComplete = (id) ->
            console.log "file complete", id
            console.log "chunks", @chunks
            @writeChunks(id)




        @suicide = ->
            @roomDir.removeRecursively(
                ->
                    console.log "successfully removed room dir"
                (error) ->
                    console.log "error on room dir removal", error
            )
            @roomDir = undefined

        @removeAllDirs = ->
            dirReader = @root.createReader()

            dirReader.readEntries( (entries) ->
                for entry in entries
                    if entry.isDirectory
                        entry.removeRecursively(->)
            )

        @listAllDirs = ->
            dirReader = @root.createReader()
            dirReader.readEntries( (entries) ->
                for entry in entries
                    if entry.isDirectory
                        console.log entry
            )

        @listAllFiles = (directory) ->
            if !directory
                dirReader = @root.createReader()
            else
                dirReader = directory.createReader()
            dirReader.readEntries( (entries) =>
                for entry in entries
                    console.log entry
                    if !entry.isDirectory
                        console.log entry.toURL()
                    else
                        @listAllFiles( entry )

            )

        return


]
