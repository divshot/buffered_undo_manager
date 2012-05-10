var BufferedUndoManager,
  __slice = [].slice;

BufferedUndoManager = (function() {

  BufferedUndoManager.name = 'BufferedUndoManager';

  function BufferedUndoManager(options) {
    this.bindings = {};
    this.options = _.extend({
      buffer: 1000,
      synchronizeOnUpdate: false,
      comparator: function(a, b) {
        return a === b;
      }
    }, options);
    this.reset(this.options.state);
  }

  BufferedUndoManager.prototype.reset = function(state) {
    delete this.undos;
    delete this.redos;
    this.undos = [];
    this.redos = [];
    this.bufferReady = true;
    return this.state = state;
  };

  BufferedUndoManager.prototype.undo = function() {
    console.log("Performing undo...");
    if (!this.canUndo()) {
      return false;
    }
    this.redos.push(this.state);
    this.state = this.undos.pop();
    this.trigger('undo', this.state);
    this.synchronize();
    return this.undos.length;
  };

  BufferedUndoManager.prototype.redo = function() {
    if (!this.canRedo()) {
      return false;
    }
    this.undos.push(this.state);
    this.state = this.redos.pop();
    this.trigger('redo', this.state);
    this.synchronize();
    return this.redos.length;
  };

  BufferedUndoManager.prototype.canUndo = function() {
    return this.undos.length > 0;
  };

  BufferedUndoManager.prototype.canRedo = function() {
    return this.redos.length > 0;
  };

  BufferedUndoManager.prototype.on = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = $(this)).on.apply(_ref, args);
  };

  BufferedUndoManager.prototype.off = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = $(this)).off.apply(_ref, args);
  };

  BufferedUndoManager.prototype.update = function(state, options) {
    var _this = this;
    if (options == null) {
      options = {};
    }
    if (this.options.comparator(this.state, state) && !options.force) {
      return false;
    }
    this.redos = [];
    if (options.force || this.bufferReady) {
      this.undos.push(this.state);
      this.trigger('push', this.state);
      this.bufferReady = false;
    }
    if (this.bufferTimeout != null) {
      clearTimeout(this.bufferTimeout);
    }
    this.bufferTimeout = setTimeout(function() {
      return _this.bufferReady = true;
    }, this.options.buffer);
    this.state = state;
    return this.synchronize(this.options.synchronizeOnUpdate != null);
  };

  BufferedUndoManager.prototype.trigger = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = $(this)).triggerHandler.apply(_ref, args);
  };

  BufferedUndoManager.prototype.synchronize = function(options) {
    this.trigger('change', this.state);
    if ((this.options.synchronize != null) && callThrough) {
      return this.options.synchronize(this.state);
    }
  };

  return BufferedUndoManager;

})();
