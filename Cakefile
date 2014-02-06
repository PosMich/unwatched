fs            = require "fs"
wrench        = require "wrench"
{print}       = require "util"
which         = require "which"
{spawn, exec} = require "child_process"
pty           = require "pty.js"
linter        = require "coffeelint"
async         = require "async"

lintConfig    = require "./coffeelint.json"

{error, warn, info, infoSuccess, infoFail} = require "./modules/debug"

debug_port    = 8989
dirs          =
  "coffee": [
    "./modules"
    "./assets/js"
  ],
  "css": [
    "./assets/css"
  ],
  "views": [
    "./views"
  ]



# ---
# ANSI Terminal Colors/Styles
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

colorize = ( input, color, bg, style... ) ->
  str = "\x1B["
  for sty in style
    str += ";" + styles[sty] if styles[sty]?
  str += ";" + colors[color] if colors[color]?
  str += ";" + backgrounds[bg] if backgrounds[bg]?
  str += "m"

  str+input+reset

color = ( clr, input ) ->
  if input?
    "\x1B[" + colors[clr] + "m"+input+reset
  else
    "\x1B[" + colors[clr] + "m"


# ---
# various symbols
symbol = (sym, option) ->
  switch sym
    when "true"                 #   ✔         #   ✓
      if option is "bold" then "\u2714" else "\u2713"
    when "false"                #   ✗         #   ✘
      if option is "bold" then "\u2717" else "\u2718"
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


# ---
# print unused exceptions
process.on "uncaughtException", ( err ) ->
  error "OMG :-S"
  error "caught 'uncaught' exception: " + err


# ---
# simple log function
log = ( message, color, explanation ) ->
  console.log color + message + reset + " " + (explanation or "")

# ---
# #getCoffeeFiles()
# >get all CoffeeScript Files
getCoffeeFiles = ->
  coffeeFiles = []

  for dir in dirs.coffee
    for file in wrench.readdirSyncRecursive dir when /\.coffee$/.test file
      coffeeFiles.push "#{dir}/#{file}"

  return coffeeFiles


# ---
# #build( successCallback, failCallback )
# >build CoffeeScript Files into .app directory
build = ( callback ) ->
  console.log color( "blue", "cooking coffee ...")

  options = ["-c","-b", "-o", ".app"].concat dirs.coffee

  cmd = which.sync "coffee"

  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr

  coffee.on "exit", ( status ) ->
    if status is 0
      console.log color("green", "Coffee is ready, enjoy it!")
      callback null
    else
      console.log color(
        "red",
        "Wasn't able to cook coffee :("
      )
      callback status

# ---
# #lint( callback )
# >lint all coffee files
lint = ( callback ) ->
  console.log color("blue", "linting files ...")

  warnings = 0
  errors   = 0

  # ---
  # >>traverse all CoffeeScript files
  for file in getCoffeeFiles()
    # >>>lint each file
    results = linter.lint fs.readFileSync(file).toString(), lintConfig

    # >>>if errors/warnings, print them
    if results.length > 0
      console.log color("red", "\t"+
        symbol("false"))+
        " "+
        color("light_gray", file)

      for result in results
        if result.level is "warn"
          ++warnings
          console.log "\t\t"+
            color("magenta" , result.lineNumber)+
            ": "+
            color("yellow", result.message)

        else if result.level is "error"
          ++errors
          console.log "\t\t#{color("magenta", result.lineNumber)}: "+
            "#{color("red", result.message)}"

    else
      console.log color("green", "\t"+symbol("true"))+" "+color("light_gray", file)

  # >> print results
  if errors > 0 or warnings > 0
    console.log "\n\r\tresult: "+
      color("yellow", symbol("warning")+" "+warnings+" warning(s)")+
      ", "+
      color("red", symbol("false")+" "+errors+" error(s)")+
      "\n\r"

    console.log color("red", "the coffee beans look like mud :(\n\r")
    callback "error"
  else
    console.log color("green", "this coffee beans are high quality shit :)\n\r")
    callback null



taskBuild = ->
  lint (err) ->
    if !err?
      build (err) ->

# ---
# #Task _build_
# >Compiles app.coffee and src directory to the .app directory
task "build"
, "compiles coffeescript files to javascript into the .app directory", taskBuild


# ---
# #Task _lint_
# >lints all CoffeeScript files
task "lint", "lints all coffeescript files", ->
  lint (err) ->



# ---
# #Task _docs_
# >generates annotated source code with Docco and move it to public dir
task "docs"
, "generates annotated source code with Docco and move it to public dir", ->
  build(
    ->

      # build was successful
      log ":)", green

      coffeeFiles = getCoffeeFiles()

      log "Coffee Files: ", bright_blue
      log "\t" + file, bright_green for file in coffeeFiles

      coffeeFiles.push "README.md"
      coffeeFiles.push "--out"
      coffeeFiles.push "./docs"

      # generate docs
      try
        cmd = which.sync "groc"
        groc = spawn cmd, coffeeFiles

        # pipe stdout & stderr to process
        groc.stdout.pipe process.stdout
        groc.stderr.pipe process.stderr
        groc.on "exit", (status) -> callback?() if status is 0
      catch err
        log err.message, red
        log "Groc is not installed - try npm install -g groc", red
  ,
    #build failed
    (err) -> log err + " :(", red
  )


#
# watches coffee, js and html files
#
task "dev", "run 'build' task, start dev env", ->
  lint (result) ->
    if result.errors > 0 or result.warnings > 0
      console.log """
        \n\rresult:
        \t#{color("magenta", result.warnings+" warnings")},
        \t#{color("red", result.errors+" errors")}

      """
      log "the coffee beans look like mud :(\n\r", red
    else
      log "this coffee beans are high quality shit :)\n\r", green
      build( ->
        # build was successful
        log ":)", green

        # watch coffee files, automatically compile them
        options = ["-c", "-b", "-w", "-o", ".app", "modules"]
        cmd = which.sync "coffee"
        coffee = spawn cmd, options
        coffee.stdout.pipe process.stdout
        coffee.stderr.pipe process.stderr

        log "Watching coffee files", green
        supervisor = new Object
        # watch js and html files and restart server if changes happend
        setTimeout ->
          supervisor = spawn "node", [
            "./node_modules/supervisor/lib/cli-wrapper.js",
            "-w",
            ".app,views",
            "-e",
            "js|html",
            "app"
          ]
          supervisor.stdout.pipe process.stdout
          supervisor.stderr.pipe process.stderr
          log "Watching js files and running server", green
        , 2000
      ,
        # build failed
        (err) -> log err + " :(", red
      )


#
# watches coffee, js and html files and starts the node inspector
#
task "debug", "run 'build' task, start debug env", ->
  build(
    ->
      # build was successful
      log ":)", green

      # watch coffee files, automatically compile them
      options = ["-c", "-b", "-w", "-o", ".app", "modules"]
      cmd = which.sync "coffee"
      coffee = spawn cmd, options
      coffee.stdout.pipe process.stdout
      coffee.stderr.pipe process.stderr
      log "Watching coffee files", green

      # run debug mode
      app = spawn "node", [
        "--debug",
        "app"
      ]
      app.stdout.pipe process.stdout
      app.stderr.pipe process.stderr

      # run node-inspector
      inspector = spawn "node-inspector", ["--web-port=" + debug_port]
      inspector.stdout.pipe process.stdout
      inspector.stderr.pipe process.stderr

      # run google chrome
      chrome = spawn "google-chrome"
      , ["http://localhost:" + debug_port + "/debug?port=5858"]

      chrome.stdout.pipe process.stdout
      chrome.stderr.pipe process.stderr
      log "Debugging server", green
  ,
    #build failed
    (err) -> log err + " :(", red
  )


#
# runs the production environment
#
task "run", "run 'build' task, start production env", ->
  build(
    ->
      # build was successful
      log ":)", green

      # start app in production environment
      cmd = spawn "node", ["app"],
        env:
          NODE_ENV: "production"
      cmd.stdout.pipe process.stdout
      cmd.stderr.pipe process.stderr
      log "Running Server in production environment", green
  ,
    # build failed
    (err) -> log err + " :(", red
  )

task "test-frontend", "run frontend tests", ->
  # karma --> jasmine --> phantomjs

task "test-backend", "run backend tests", ->
  # --> jasmine only

task "test", "run all tests", ->

