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
    atom.workspaceView = new WorkspaceView()
    activationPromise  = (atom.packages.activatePackage 'erlang-build')

  describe "in a well-formed project", ->
    beforeEach ->
      # Change path to our fixture of a well-formed dummy app
      atom.project.setPath (path.join __dirname, 'fixtures', 'apps', 'dummy')

    describe "before erlang-build:compile is triggered", ->
      it "has no message panel", ->
        # Test the "before" state of our message panel
        (expect (atom.workspaceView.find '.am-panel')).not.toExist()

    describe "after erlang-build:compile is triggered", ->
      beforeEach ->
        atom.workspaceView.trigger 'erlang-build:compile'

        waitsForPromise ->
          activationPromise

        runs ->
          # this will help keep us in-synch since our compile process
          # is asynch and doesn't provide any promises to watch
          @messagePanel =
            (atom.packages.getActivePackage 'erlang-build').mainModule.messagePanelView
          (spyOn @messagePanel, 'attach').andCallThrough()

        waitsFor ->
          # Our code calls the displayMessage method just once
          @messagePanel.attach.callCount == 1

      it "displays a message panel with successful compile messages", ->
        # Does the message panel exist?
        (expect (atom.workspaceView.find '.am-panel')).toExist()
        # Does it contain the correct content?
        (expect atom.workspaceView.find('.plain-message').text() ).
          toEqual "Application: dummy compiled successfully."

  describe "in a malformed project", ->
    beforeEach ->
      # Change path to our fixture of a well-formed dummy app
      atom.project.setPath (path.join __dirname, 'fixtures', 'apps', 'bad-dummy')

      waitsForPromise ->
        activationPromise

      runs ->
        # this will help keep us in-synch since our compile process
        # is asynch and doesn't provide any promises to watch
        @messagePanel =
          (atom.packages.getActivePackage 'erlang-build').mainModule.messagePanelView
        (spyOn @messagePanel, 'attach').andCallThrough()

    describe "after erlang-build:compile is triggered", ->
      beforeEach ->
        atom.workspaceView.trigger 'erlang-build:compile'

      waitsFor ->
        # Our code calls the displayMessage method just once
        @messagePanel.attach.callCount == 1

      it "displays a message panel with errored compile messages", ->
        # Change path to our fixture of a malformed dummy app
        atom.project.setPath (path.join __dirname, 'fixtures', 'apps', 'bad-dummy')
        # Does the message panel exist?
        (expect (atom.workspaceView.find '.am-panel')).toExist()
        # Does it contain the correct content?
        (expect atom.workspaceView.find('.line-message').length).
          toEqual 16
