{WorkspaceView} = require 'atom'
path = require 'path'
ErlangBuild = require '../lib/erlang-build'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ErlangBuild", ->
  activationPromise = null

  beforeEach ->
    # Change path to our fixture of a well-formed dummy app
    atom.project.setPath (path.join __dirname, 'fixtures', 'apps', 'dummy')
    atom.workspaceView = new WorkspaceView()
    activationPromise  = (atom.packages.activatePackage 'erlang-build')

  describe "before erlang-build:compile is triggered", ->
    it "has no message panel", ->
      # Test the "before" state of our message panel
      (expect (atom.workspaceView.find '.am-panel')).not.toExist()

  describe "after erlang-build:compile is triggered", ->
    it "displays a message panel with compile messages", ->
      atom.workspaceView.trigger 'erlang-build:compile'

      waitsForPromise ->
        activationPromise

      runs ->
        # this will help keep us in-synch since our compile process
        # is asynch and doesn't provide any promises to watch
        @erlangBuildPackage = (atom.packages.getActivePackage 'erlang-build').mainModule
        (spyOn @erlangBuildPackage, 'displayMessage').andCallThrough()

      waitsFor ->
        # Our code calls the displayMessage method twice
        @erlangBuildPackage.displayMessage.callCount == 2

      runs ->
        # Does the message panel exist?
        (expect (atom.workspaceView.find '.am-panel')).toExist()
        (expect atom.workspaceView.find('.plain-message').text() ).
          toEqual "COMPILE: ==> dummy (compile)\nCOMPILE: exited with code: 0"
