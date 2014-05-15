{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
Path = require 'path'
{spawn} = require 'child_process'
CompileStatus = require './compile-status'

module.exports =
  messagePanelView: null

  configDefaults:
    compileOnSave: true

  activate: (state) ->
    atom.workspaceView.command "erlang-build:compile", => @compile()
    process.env.PATH = "#{process.env.PATH}:/usr/local/bin"
    @setupCompileOnSave()

  deactivate: ->

  serialize: ->

  compile: ->
    @resetPanel()
    proc = spawn "/usr/local/bin/rebar", ['compile'], cwd: atom.project.path
    status = new CompileStatus
    proc.stdout.pipe status
    proc.stdout.on 'end',  () =>
      for app, errors of status.errors
        if errors.length > 0
          @displayMessage "Application: #{app} has compilation errors:"
          @displayMessage error for error in errors
        else
          @displayMessage "Application: #{app} compiled successfully."

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

  resetPanel: ->
    if (atom.workspaceView.find '.am-panel').length != 1
      @messagePanelView = new MessagePanelView
        title: '<span class="icon-diff-added"></span> erlang-build'
        rawTitle: true
      @messagePanelView.attach()
    else
      @messagePanelView.clear()

  displayMessage: (msg) ->
    if typeof msg == "string"
      @messagePanelView.add new PlainMessageView message: msg
    else if typeof msg == "object"
      @messagePanelView.add new LineMessageView msg
    else
      console.log typeof msg
