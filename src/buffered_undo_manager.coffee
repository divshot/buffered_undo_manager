# The Buffered Undo Manager is a simple way to provide an
# undo/redo stack for a Javascript application.
#
# **Prerequisites:** Requires that jQuery and Underscore both
# be installed.
class BufferedUndoManager
  # ## new BufferedUndoManager(options)
  # 
  # Initializes a new undo manager with the provided options.
  # Options may be specified as follows:
  #
  # * **buffer:** The amount of time (in ms) to buffer updates before
  #   allowing another push to the undo stack. Defaults to `1000`.
  # * **synchronize:** A callback that is called after undos and redos,
  #   allowing you to update data or displays. Alternatively see the
  #   `on` and `off` methods for binding to events instead.
  # * **synchronizeOnUpdate:** Whether or not to call the `synchronize`
  #   method when `update` is called in addition to `undo` and `redo`.
  # * **comparator:** A function that takes two arguments `a` and `b`
  #   and returns `true` if they are identical and `false` if they
  #   are not. Used to avoid pushing duplicate states to the stack.
  #   Defaults to naive equality.
  constructor: (options)->
    @bindings = {}
    @options = _.extend
      buffer: 1000
      synchronizeOnUpdate: false
      comparator: (a,b)->
        a == b
    , options

    @reset(@options.state)

  # ## manager.reset(state)
  #
  # Resets the undo manager to a blank slate.
  # Useful if you are using an application-wide
  # undo manager and have loaded a different editable
  # resource, for instance.
  #
  # ### Arguments
  #
  # * **state:** The 'initial' state to which to reset.
  reset: (state, options = {})->
    @clearTimeout()
    delete @undos
    delete @redos
    delete @bufferTimeout
    @undos = []
    @redos = []
    @bufferReady = true
    @state = state

  # ## manager.undo()
  #
  # Performs an undo operation. This operation will
  # run the `synchronize` callback if present and will
  # also trigger an `undo` event.
  undo: ->
    return false unless @canUndo()
    @redos.push @state
    @state = @undos.pop()
    @trigger 'undo', @state
    @synchronize()
    @undos.length

  # ## manager.redo()
  #
  # Performs a redo operation. This operation will
  # run the `synchronize` callback if present and will
  # also trigger a `redo` event.
  redo: ->
    return false unless @canRedo()
    @undos.push @state
    @state = @redos.pop()
    @trigger 'redo', @state
    @synchronize()
    @redos.length

  # ## manager.canUndo()
  #
  # Returns `true` if there are any states to undo
  # to, `false otherwise.
  canUndo: ->
    @undos.length > 0
  # ## manager.canRedo()
  #
  # Returns `true` if there are any states to redo
  # to, `false otherwise.
  canRedo: ->
    @redos.length > 0

  # ## manager.on(event, handler)
  #
  # Takes a string of space-separated events and
  # calls the provided handler function when the given
  # events trigger. Available events are:
  #
  # * undo
  # * redo
  # * change
  # * push
  # * buffered
  on: (args...)->
    $(this).on args...
  # ## manager.off(event, [handler])
  #
  # Takes an event string and optional handler. If handler
  # is provided only that specific handler will be unbound.
  # Otherwise all handlers will be unbound.
  off: (args...)->
    $(this).off args...

  # ## manager.update(state, options)
  # 
  # Update the state of the undo manager.
  #
  # ### Arguments
  #
  # * **state:** The new state. Can be anything.
  # 
  # ### Options
  #
  # * **force:** if set to `true` then this update
  #   will ignore buffering and immediately trigger
  #   a new undo state regardless of current buffering.
  update: (state, options = {})->
    return false if @options.comparator(@state, state) and !options.force

    @redos = []

    if options.force or @bufferReady  
      @undos.push @state
      @trigger 'push', @state
      @bufferReady = false
    
    @clearTimeout()
    @bufferTimeout = setTimeout =>
      @trigger 'buffered', @state
      @bufferReady = true
    , @options.buffer

    @state = state
    @synchronize(@options.synchronizeOnUpdate?)

  clearTimeout: ->
    clearTimeout @bufferTimeout if @bufferTimeout?

  trigger: (args...)->
    $(this).triggerHandler args...

  synchronize: (options)->
    @trigger 'change', @state
    @options.synchronize @state if @options.synchronize? and callThrough