{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
Path = require 'path'
{spawn} = require 'child_process'
CompileStatus = require './compile-status'

module.exports =
  messagePanelView: null

  configDefaults:
    compileOnSave: true
    erlangPath: "/usr/local/bin"
    rebarPath: "/usr/local/bin"

  activate: (state) ->
    atom.workspaceView.command "erlang-build:compile", => @compile()
    @setupPathOptions()
    @setupCompileOnSave()

  deactivate: ->

  serialize: ->

  compile: ->
    @resetPanel()
    proc = spawn @rebarBin(), ['compile'], cwd: atom.project.path
    status = new CompileStatus
    proc.stdout.pipe status
    proc.stdout.on 'end',  () =>
      for app, errors of status.errors
        if errors.length > 0
          @displayMessage "Application: #{app} has compilation errors:"
          @displayMessage error for error in errors
        else
          @displayMessage "Application: #{app} compiled successfully."
      @done()

  setupPathOptions: ->
    atom.config.observe 'erlang-build.erlangPath', {callNow: true}, (val) ->
      process.env.PATH = "#{process.env.PATH}:#{val}"

  setupCompileOnSave: ->
    compileHandler = ->
      editor = atom.workspace.getActiveEditor()
      if editor? and editor.getGrammar().name != 'Erlang' then return

      atom.workspaceView.trigger 'erlang-build:compile'

    atom.config.observe 'erlang-build.compileOnSave', {callNow: true}, (val) ->
      if val
        atom.workspace.eachEditor (ed) -> ed.buffer.on  'saved', compileHandler
      else
        atom.workspace.eachEditor (ed) -> ed.buffer.off 'saved', compileHandler

  done: ->
    console.log 'tasks completed'

  resetPanel: ->
    if (atom.workspaceView.find '#erlang-build-mp').length > 0
      @messagePanelView.clear()
    else
      @messagePanelView = new MessagePanelView
        title: '<span class="icon-diff-added"></span> erlang-build'
        rawTitle: true
      @messagePanelView.attr 'id', 'erlang-build-mp'
      @messagePanelView.attach()

  displayMessage: (msg) ->
    if typeof msg == "string"
      @messagePanelView.add new PlainMessageView message: msg
    else if typeof msg == "object"
      @messagePanelView.add new LineMessageView msg
    else
      console.log typeof msg

  rebarBin: ->
    Path.join (atom.config.get 'erlang-build.rebarPath'), 'rebar'
