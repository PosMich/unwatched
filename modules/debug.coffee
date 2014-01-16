# ***
# ### Debug Outputs
# ***
config = require "./config"
sty    = require "sty"


debug = {}

style = {}

style.error       = "#{sty.bgwhite sty.black config.appName} #{sty.red sty.bold 'ERROR:'} "
style.warn        = "#{sty.bgwhite sty.black config.appName} #{sty.yellow 'WARNING:'} "
style.info        = "#{sty.bgwhite sty.black config.appName} #{sty.cyan 'INFO:'} "
style.infoSuccess = "#{sty.green 'SUCCESS: '}"
style.infoFail    = "#{sty.red 'FAIL: '}"


# ***
# prints error message formatted
debug.ferror = (msg) ->
  return unless config.DEBUG_ERROR
  console.log style.error+format(msg)

# ***
# prints warn message formatted
debug.fwarn = (msg) ->
  return unless config.DEBUG_WARN
  console.log style.warn+format(msg)

# ***
# print info message formatted
debug.finfo = (msg) ->
  return unless config.DEBUG_LOG
  console.log style.info+format(msg)

# ***
# print "success" info message formatted
debug.finfoSuccess = (msg) ->
  return unless config.DEBUG_LOG
  debug.info style.infoSuccess+format(msg)

# ***
# print "fail" info message formatted
debug.finfoFail = (msg) ->
  return unless config.DEBUG_LOG
  debug.info style.infoFail+format(msg)


# ***
# prints error message unformatted
debug.error = (msg) ->
  return unless config.DEBUG_ERROR
  console.log style.error+msg

# ***
# prints warn message unformatted
debug.warn = (msg) ->
  return unless config.DEBUG_WARN
  console.log style.warn+msg

# ***
# print info message unformatted
debug.info = (msg) ->
  return unless config.DEBUG_LOG
  console.log style.info+msg

# ***
# print "success" info message unformatted
debug.infoSuccess = (msg) ->
  return unless config.DEBUG_LOG
  debug.info style.infoSuccess+msg

# ***
# print "fail" info message unformatted
debug.infoFail = (msg) ->
  return unless config.DEBUG_LOG
  debug.info style.infoFail+msg




# ***
# simple typeof alternative
type = (obj) ->
  if obj == undefined or obj == null
    return String obj
  classToType = {
    "[object Boolean]": "boolean",
    "[object Number]": "number",
    "[object String]": "string",
    "[object Function]": "function",
    "[object Array]": "array",
    "[object Date]": "date",
    "[object RegExp]": "regexp",
    "[object Object]": "object"
  }
  return classToType[Object.prototype.toString.call(obj)]
# ***
# used to format vars/objs/whatever for debug output
format = (data, indent) ->
  result = ""
  indent = ""  unless indent?

  switch( type(data) )
    when "boolean"
      result = "#{sty.yellow 'Boolean:'} "+data

    when "number"
      result = "#{sty.yellow 'Number:'} "+data

    when "string"
      result = "#{sty.yellow 'String:'} "+data

    when "function"
      result = "#{sty.yellow 'Function:'} "+data

    when "array"
      value = ""
      for item of data
        value += format( data[item], indent )
      result = "#{sty.yellow 'Array:'} ["+value+"]"

    when "date"
      result = "#{sty.yellow 'Date:'} "+data

    when "regexp"
      result = "#{sty.yellow 'regexp:'} "+data

    when "object"
      result = "#{sty.yellow 'Object:'} { "
      for property of data
        value = data[property]

        switch( type(data[property]) )
          when "object"
            formattedObj = format( value, indent+"  " )
            value = "\n"+indent+"{\n"+formattedObj+"\n"+indent+"}"
          else
            value = format( value )
        result += indent+"'"+property+"' : "+value+",\n"
      result += " }"
      result.replace /,\n$/, ""
  return result

module.exports = debug