{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
Path = require 'path'
{spawn} = require 'child_process'
CompileStatus = require './compile-status'

module.exports =
config:
    executablePath:
      type: 'string'
      title: 'Werl Executable Path'
      default: 'C:/'
    rebarPath:
      type: 'string'
      title: 'Rebar Path'
      default: 'C:/'

  activate: (state) ->
    atom.commands.add 'atom-workspace',
    "erlang-build:compile": => @compile()

  deactivate: ->

  serialize: ->

  compile: ->
    console.log atom.project.getPaths()[0]
    console.log atom.config.get 'erlang-build.rebarPath'
    ls = spawn "#{atom.config.get 'erlang-build.rebarPath'}", ["compile"],
        cwd: "#{atom.project.getPaths()[0]}"
    erl = spawn "#{atom.config.get 'erlang-build.executablePath'}", [],
        cwd: "#{atom.project.getPaths()[0]}/ebin"
# receive all output and process
    ls.stdout.on 'data', (data) -> console.log data.toString().trim()
# receive error messages and process
    ls.stderr.on 'data', (data) -> console.log data.toString().trim()
