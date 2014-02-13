# # requires

wrench        = require "wrench"
which         = require "which"
{spawn, exec} = require "child_process"

# # config
debug_port    = 8989
env           = process.env
dirs          =
  "coffee": [
    "./modules"
    "./assets/js"
  ]
  "css": [
    "./assets/css"
  ]
  "views": [
    "./views"
  ]


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
#{reset}\x1B[#{backgrounds.black}m


"""

header = header.replace /█/g, "#{reset}\x1B[#{backgrounds.black};#{colors.green}m█#{reset}"
for char in ["╗","╝","║","═","╔","╚"]
  header = header.replace new RegExp(char, "g"),
    "#{reset}\x1B[#{backgrounds.black};#{colors.light_blue}m#{char}#{reset}"

console.log header

# ***
# ## `colorize( input, color, bg, style... )`
# > adds styles/colors/backgrounds to an input string
colorize = ( input, color, bg, style... ) ->
  str = "\x1B["
  for sty in style
    str += ";" + styles[sty] if styles[sty]?
  str += ";" + colors[color] if colors[color]?
  str += ";" + backgrounds[bg] if backgrounds[bg]?
  str += "m"

  str+input+reset

# ***
# ## `color( clr, input )`
# > simple colors _input_ string
color = ( clr, input ) ->
  if input?
    "\x1B[" + colors[clr] + "m"+input+reset
  else
    "\x1B[" + colors[clr] + "m"


# ***
# ## `symbol( sym, option )`
# > get various symbols
symbol = (sym, option) ->
  switch sym
    when "true"                 #   ✔         #   ✓
      if option is "bold" then "\u2714" else "\u2713"
    when "false"                #   ✗         #   ✘
      if option is "bold" then "\u2718" else "\u2717"
    when "warning"   then "\u26A1" # ⚡
    when "box"
      switch option
        when "true"  then "\u2611" # ☑
        when "false" then "\u2612" # ☒
        else "\u2610"              # ☐
    when "smilie"
      switch option
        when "bad"   then "\u2639" # ☹
        when "good"  then "\u263A" # ☺
        else "\u263B"              # ☻
    when "clock"     then "\u231A" # ⌚
    when "hourglass" then "\u231B" # ⌛
    when "keyboard"  then "\u2328" # ⌨
    when "high-5"    then "\u270B" # ✋
    when "attention" then "\u26A0" # ⚠
    when "heart"     then "\u2665" # ♥
    when "coffee"              #   ♨         #   ☕
      if option is "alt" then "\u2668" else "\u2615"
    when "skull"     then "\u2620" # ☠

# ***
# ## `log( message, txtColor, explanation )`
# > simple log function
# >
# > *message* &rarr; log _string_
# > *txtColor* &rarr; _color string_
# > *explanation* &rarr; _additional explanation_
log = ( message, txtColor, explanation ) ->
  if txtColor
    message = color(txtColor, message)
  console.log message + " " + (explanation or "")


# ***
# print unused exceptions
process.on "uncaughtException", ( err ) ->
  log "OMG :-S", "red"
  log "caught 'uncaught' exception: " + err, "red"


# ***
# # getCoffeeFiles()
# > get all CoffeeScript Files
getCoffeeFiles = ->
  coffeeFiles = []

  for dir in dirs.coffee
    for file in wrench.readdirSyncRecursive dir when /\.coffee$/.test file
      coffeeFiles.push "#{dir}/#{file}"

  return coffeeFiles


# ***
# # Run( command, options, env, properties )
# > spawns a command
# > *command* &rarr; command name
# > *options* &rarr; options array
# > *env* &rarr; additional environment vars
# > *properties* &rarr; json containing:
# >> *pipeStdOut* &rarr; Boolean, set to false if _stdout_ should be emitted
# >> *pipeStdErr* &rarr; Boolean, set to false if _stderr_ should be emitted
EventEmitter = require('events').EventEmitter
class Run extends EventEmitter
  constructor: (command, options, env, properties) ->
    @env        = process.env
    @properties =
      pipeStdOut: true
      pipeStdErr: true

    @env[attr]        = val for attr, val of env
    @properties[attr] = val for attr, val of properties

    try
      @app = spawn which.sync(command), options, env

      if @properties.pipeStdOut
        @app.stdout.pipe process.stdout
      else
        @app.stdout.on "data", (data) =>
          @.emit "stdout", data

      if @properties.pipeStdErr
        @app.stderr.pipe process.stderr
      else
        @app.stderr.on "data", (data) =>
          @.emit "stderr", data

      @app.on "exit", (args...)=>
        @.emit "exit", args

    catch err
      log err, "red"
      log command+" not installed?", "magenta"

  kill: ->
    @app.kill()


# ***
# ## `build( callback )`
# > build CoffeeScript Files into .app directory
build = ( callback ) ->
  log "cooking coffee ...", "blue"

  options = ["-c","-b", "-o", ".app"].concat dirs.coffee

  coffee = new Run "coffee", options
  coffee.on "exit", (args) ->
    if args[0] is 0
      log "Coffee is ready, enjoy it!\n", "green"
      callback null
    else
      log "Wasn't able to cook coffee :(\n", "red"
      callback args[0]

# ***
# # `lint( callback )`
# > lint all coffee files
lint = (callback) ->
  log "linting Files ...", "blue"

  opts = ["-f", "coffeelint.json"].concat dirs.coffee

  linter = new Run "coffeelint", opts, null,
    pipeStdOut: false

  #  pipeStdErr: false

  linter.on "stdout", (data) ->
    str = data.toString()
    str = str.replace new RegExp(symbol("true"), "g"),
      color("green", symbol("true"))
    str = str.replace new RegExp(symbol("false"), "g"),
      color("red", symbol("false"))
    console.log str

  linter.on "exit", (args) ->
    callback args[0]

# ***
# ## `buildTask( callback )`
# > lints and builds all coffee files
buildTask = (callback) ->
  lint (err) ->
    if err
      callback err
    else
      build (err) ->
        callback err

# ***
# ## Task _build_
# > Compiles app.coffee and src directory to the .app directory
task "build"
, "compiles coffeescript files to javascript into the .app directory", ->
  buildTask (err) ->
    if err
      log err, "red"

# ***
# ## Task _lint_
# > lints all CoffeeScript files
task "lint", "lints all coffeescript files", ->
  lint (err) ->
    if err
      log err, "red"



# ***
# # Task _docs_
# > generates annotated source code with Docco and move it to public dir
task "docs"
, "generates annotated source code with groc and move it to public dir", ->

  lint (err) ->
    if err
      log err, "red"
    else
      coffeeFiles = getCoffeeFiles()
        .concat ["README.md", "--out", "./public/docs"]...

      # generate docs
      try
        groc = new Run "groc", coffeeFiles, null,
          pipeStdOut: false

        console.log color("light_blue", "\ngenerating Documentation...")
        groc.on "stdout", (data) ->
          # ***
          # > remove unnecessary styling
          str = data.toString().replace /\n/g, ""
          str = str.replace /\\u001b\[[0-9]+m/g, ""

          str = str.replace new RegExp(symbol("true"), "g"),
              color("green", "  "+symbol("true"))

          str = str.replace "  ", "" if str.match("Documentation generated")

          console.log str if str isnt ""




#
# watches coffee, js and html files
#
task "dev", "run 'build' task, start dev env", ->
  buildTask (err) ->
    if err
      log err, "red"
    else
      # watch coffee files, automatically compile them
      new Run "coffee", [
        "-c"
        "-b"
        "-w"
        "-o"
        ".app"
        "modules"
      ]
      log "Watching coffee files", "green"

      # watch js and html files and restart server if changes happend
      try
        new Run "node", [
          "./node_modules/supervisor/lib/cli-wrapper.js"
          "-w"
          ".app,views"
          "-e"
          "js|html"
          "app"
        ]
        log "Watching js files and running server", "green"
      catch err
        log err.message, "red"
        log "supervisor/node is not installed?", "red"


#
# watches coffee, js and html files and starts the node inspector
#
task "debug", "run 'build' task, start debug env", ->
  buildTask (err) ->
    if err
      log err, "red"
    else
      # watch coffee files, automatically compile them
      options = ["-c", "-b", "-w", "-o", ".app", "modules"]
      try
        coffee = new Run "coffee", [
          "-c"
          "-b"
          "-w"
          "-o"
          ".app"
          "modules"
        ]
      catch err
        log err.message, "red"
        log "cofee is not installed?", "red"

      if coffee
        log "Watching coffee files", "green"

        try
          # run debug mode
          app = new Run "node", [
            "--debug"
            "app"
          ]

          # run node-inspector
          inspector = new Run "node-inspector", ["--web-port=" + debug_port]
        catch err
          log err.message, "red"
          log "node/node-inspector is not installed?", "red"

      if app
        try
          # run google chrome
          new Run "google-chrome", [
            "http://localhost:" + debug_port + "/debug?port=5858"
          ]
        catch err
          log err.message, "red"
          log "chrome is not installed?", "red"
          try
            new Run "firefox", [
              "http://localhost:" + debug_port + "/debug?port=5858"
            ]
          catch err
            log err.message, "red"
            log "firefox is not installed?", "red"




#
# runs the production environment
#
task "run", "run 'build' task, start production env", ->
  buildTask (err) ->
    if err
      log err, "red"
    else
      try
        # start app in production environment
        new Run "node", ["app"],
          NODE_ENV:"production"

        log "Running Server in production environment", "green"
      catch err
        log err.message, "red"
        log "node not installed?", "red"



task "test-backend", "run backend tests", ->
  # --> jasmine only
  buildTask (err) ->
    if err
      log err, "red"
    else
      try
        app = new Run "node", ["app"],
          NODE_ENV: "production"
        ,
          pipeStdOut: false
          pipeStdErr: false

        app.on "stdout", (data) ->
          if data.toString().match "Press CTRL-C to stop server"
            app.removeAllListeners "stdout"
            try
              jasmine = new Run "jasmine-node", [
                "--coffee"
                "spec/backend"
                "--verbose"
                "--color"
                "--forceexit"
              ]

              jasmine.on "exit", ->
                app.kill()
            catch err
              log err.message, "red"
              log "jasmine-node not installed?", "red"

      catch err
        log err.message, "red"
        log "problem when starting server"



task "test-frontend", "run frontend tests", ->
  # karma --> jasmine --> phantomjs



task "test", "run all tests", ->


