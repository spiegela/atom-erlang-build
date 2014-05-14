Transform = (require 'stream').Transform

module.exports =
class CompileStatus extends Transform

  errors: {}

  clear: -> @currentApp = null; @errors = {}

  _transform: (chunk, encoding, done) ->
    @_parseCompileLine line for line in (chunk.toString().split "\n")
    done()

  _parseCompileLine: (line) ->
    if matches = (line.match /^==> (.+) \(compile\)$/)
      # Record the current app so that we store the errors appropriately
      @currentApp = matches[1]
      # Store a list of errors for each app
      @errors[ @currentApp ] = []

    else if matches = (line.match /^(.+):(\d+): (Warning: )?(.+)$/)
      [ file, line, warn, message ] = matches[ 1..4 ]
      # className = warn ? 'warning' : 'error'
      @errors[ @currentApp ].push file: file, line: line, message: message
