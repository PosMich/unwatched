path = require "path"
LIVERELOAD_PORT = 35729

module.exports = (grunt) ->
    # # ANSI Terminal Colors/Styles
    reset = "\x1B[0m"

    styles =
        bold       : 1
        dim        : 2
        italic     : 3
        underlined : 4
        blink      : 5
        inverted   : 7

    colors =
        black         : 30
        white         : 97
        red           : 31
        light_red     : 91
        green         : 32
        light_green   : 92
        yellow        : 33
        light_yellow  : 93
        blue          : 34
        light_blue    : 94
        magenta       : 35
        light_magenta : 95
        cyan          : 36
        light_cyan    : 96
        gray          : 90
        light_gray    : 37

    backgrounds =
        black          : 40
        red            : 41
        green          : 42
        yellow         : 43
        blue           : 44
        magenta        : 45
        cyan           : 46
        gray           : 100
        light_red      : 101
        light_green    : 102
        light_yellow   : 103
        light_blue     : 104
        light_magenta  : 105
        light_cyan     : 106
        light_gray     : 47

    # # Header
    g  = reset+"\x1B[#{backgrounds.black};#{colors.green}m"
    lg = reset+"\x1B[#{backgrounds.black};#{colors.light_green}m"

    header = """
    \x1B[#{backgrounds.black}m



     ██╗   ██╗███╗   ██╗██╗    ██╗ █████╗ ████████╗ ██████╗██╗  ██╗███████╗██████╗
     ██║   ██║████╗  ██║██║    ██║██╔══██╗╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔══██╗
     ██║   ██║██╔██╗ ██║██║ █╗ ██║███████║   ██║   ██║     ███████║█████╗  ██║  ██║
     ██║   ██║██║╚██╗██║██║███╗██║██╔══██║   ██║   ██║     ██╔══██║██╔══╝  ██║  ██║
     ╚██████╔╝██║ ╚████║╚███╔███╔╝██║  ██║   ██║   ╚██████╗██║  ██║███████╗██████╔╝
      ╚═════╝ ╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═════╝
    #{reset}\x1B[#{backgrounds.black};#{colors.light_blue}m
                                                      - pretty close collaboration
    #{reset}

    """

    header = header.replace /█/g, "#{reset}\x1B[#{backgrounds.black};#{colors.green}m█#{reset}"
    for char in ["╗","╝","║","═","╔","╚"]
        header = header.replace new RegExp(char, "g"),
            "#{reset}\x1B[#{backgrounds.black};#{colors.light_blue}m#{char}#{reset}\x1B[#{backgrounds.black}m"

    console.log header

    require( "load-grunt-tasks" )(grunt)
    require( "time-grunt" )(grunt)

    files = 
        libDir: "assets/js/lib"
        libs: [
            "jquery-2.0.3.js"
            "bootstrap.js"
            "angular.js"
            "angular-route.js"
            "tinymce.full.min.js"
            "ui-bootstrap-tpls-0.10.0.js"
            "ng-FitText.js"
            "ui-tinymce.js"
        ]

        angularAppCoffeeFilesDir: "assets/js/angular-app"
        angularAppCoffeeFiles: [
            "controllers.coffee"
            "filters.coffee"
            "services.coffee"
            "directives.coffee"
            "angular.coffee"
        ]
        angularJsOutput: "public/js/app.js"

        getAngularAppCoffeeFiles: ->
            path = files.angularAppCoffeeFilesDir
            _files = files.angularAppCoffeeFiles
            fileArray = []
            fileArray.push( path + "/" + file ) for file in _files
            return fileArray
        getAppFiles: ->
            fileArray = []
            fileArray.push( files.libDir + "/" + lib ) for lib  in files.libs
            fileArray.push files.angularJsOutput
            return fileArray
        serverFiles: [ "modules/*.coffee" ]


    grunt.initConfig
        coffeelint:
            server: files.serverFiles
            app: files.getAngularAppCoffeeFiles()
            options:
                configFile: "coffeelint.json" 
        coffee:
            server:
                files: [      
                    expand: true
                    flatten: true
                    src: files.serverFiles
                    dest: ".app/"   
                    ext: ".js"
                    extDot: "last"
                ]
            app:
                files:
                    "public/js/app.js": files.getAngularAppCoffeeFiles()
        stylus:
            compile:
                files:
                    "public/css/app.css":"assets/css/app.styl"
                options:
                    "include css": true
                    "linenos": true
                    "compress": false

        concat:
            app:
                src:  files.getAppFiles() 
                dest: files.angularJsOutput

        cssmin:
            app:
                options:
                    keepSpecialComments: 0
                files:
                    "public/css/app.css": ["public/css/app.css"]

        uglify:
            options:
                mangle: true
                drop_console: true
            production:
                files:
                    "public/js/app.js": ["public/js/app.js"]
            debug:
                options:
                    drop_console: false
                    beautify: true
                files:
                    "public/js/app.js": ["public/js/app.js"]
        build:
            production:
                taskList: [
                    "coffeelint"
                    "coffee"
                    "stylus"
                    "concat"
                    "cssmin"
                    "uglify:production"
                ]
            dev:
                taskList: [
                    "coffeelint"
                    "coffee"
                    "stylus"
                    "concat"
                ]
            debug:          
                taskList: [
                    "coffeelint"
                    "coffee"
                    "stylus"
                    "concat"
                    "cssmin"
                    "uglify:debug"
                ]

        serve:
            production:
                taskList: [
                    "build:production"
                    "groc"
                    "nodemon:production"
                ]
            dev:
                taskList: [
                    "build:dev"
                    "concurrent:dev"
                ]
            debug:          
                taskList: [
                    "build:debug"
                    "concurrent:debug"
                ]

        watch: 
            options:
                spawn: false
                livereload: LIVERELOAD_PORT
            css:
                files: "assets/css/**/*.*"
                tasks: ["stylus"]
            jade:
                files: "views/**/*.*"
            jsApp:
                files: "assets/js/**/*.*"
                tasks: ["coffeelint:app", "coffee:app", "concat"]
            jsServer:
                files: "modules/*.*"
                tasks: ["coffeelint:server", "coffee:server"]
            APITests:
                files: ["spec/backend/**/*.*", "modules/**/*.*"] 
                tasks: ["delayAPITests"]
            

        "node-inspector":
            debug:
                options:
                    hidden: ["node_modules"]
        
        concurrent:
            options:
                logConcurrentOutput: true   
            debug: 
                tasks: [
                    "nodemon:debug"
                    "node-inspector:debug"
                    "watch:jsServer"
                ]
            dev:
                tasks: [
                    "nodemon:dev"
                    "watch"
                ]   
            testAll:
                tasks: [
                    "nodemon:testing"
                    "delayAllTests"
                ] 
            testAPI:
                tasks: [
                    "nodemon:testing"
                    "delayAPITests"
                    "watch:APITests"
                ] 
            testFrontend_e2e:
                tasks: [
                    "nodemon:testing"
                    "delayFrontendE2eTests"
                ]
            testFrontend_unit:
                tasks: [
                    "karma:unit"
                ]

        nodemon:
            options:
                watch: ["modules", "public/js", "public/css"]
                callback:  (nodemon) ->
                    nodemon.on "log", (event) ->
                        console.log event.colour
                    

                    nodemon.on "config:update", ->
                        setTimeout -> 
                            require("open")("http://localhost:3000")
                        , 1000

                    nodemon.on "restart", ->
                        setTimeout ->
                            require("fs").writeFileSync( ".rebooted", "rebooted" )      
                        , 1000
                    
            debug:
                script: "app.js"
                options:
                    nodeArgs: ["--debug"]
                    callback: (nodemon) ->
                        nodemon.on "log", (event) ->
                            console.log event.colour
                        
                        nodemon.on "config:update", ->
                            setTimeout ->
                                open = require("open") 
                                open("http://localhost:3000")
                                open("http://localhost:8080/debug?port=5858")
                            , 1000

                        nodemon.on "restart", ->
                            setTimeout ->
                                require("fs").writeFileSync( ".rebooted", "rebooted" )      
                            , 1000
            dev:
                script: "app.js"
            production:
                options:
                    watch:  []
                script: "app.js"
            testing:
                script: "app.js"
                options:
                    callback: (nodemon) =>

    
        groc:
            all: [ "./modules/*.coffee", "./assets/js/**/*.coffee", "README.md" ]
            options: 
                out: "public/docs/"
        
        jasmine_node:
            options:
                coffee: true
            backend: ["spec/backend"]

        karma:
            e2e:
                configFile: "spec/frontend/config/karma-e2e.config.coffee"
            unit:
                configFile: "spec/frontend/config/karma.config.coffee"
            unit_dev:
                configFile: "spec/frontend/config/karma.config.coffee"
                options:
                    singleRun: false
                    autoWatch: true

        test:
            all:
                ["concurrent:testAll"]
            api:
                ["concurrent:testAPI"]
            frontend: 
                ["test:frontend_unit", "test:frontend_e2e"]
            frontend_unit:
                ["concurrent:testFrontend_unit"]
            frontend_e2e:
                ["concurrent:testFrontend_e2e"]
            frontend_dev:
                ["karma:unit_dev"]

    grunt.registerTask "timeout", "create a timeout for :duration (default: 15000)", (duration = 1500)->
        done = this.async()

        setTimeout ->
            done()
        , duration


    grunt.registerTask "delayAPITests", ["timeout", "jasmine_node"]
    grunt.registerTask "delayFrontendE2eTests", ["timeout", "karma:e2e"]
    grunt.registerTask "delayAllTests", ["timeout", "jasmine_node", "karma"]

    grunt.registerTask "test","run test:* | available: all (=default), api, frontend, frontend_unit, frontend_e2e, frontend_dev", (type = "all") ->
        grunt.task.run grunt.config("test."+type)



    grunt.registerTask "docs", ["coffeelint", "groc"]          

    grunt.registerTask "default", [ "build:dev" ]

    grunt.registerTask "build", "build assets for :environment | available: production (=default), dev, debug", (env = "production") ->
        grunt.task.run grunt.config("build."+env+".taskList")

    grunt.registerTask "serve", "serve app in :environment | available: production (=default), dev, debug", (env = "production") ->
        grunt.task.run grunt.config("serve."+env+".taskList")


    grunt.registerTask "server", "alias for serve", (env) ->
        grunt.log.warn "The `server` task has been deprecated. Use `grunt serve` to start a server."
        if env?
            grunt.task.run "serve:"+env
        else
            grunt.task.run "serve"


