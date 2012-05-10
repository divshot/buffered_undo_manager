# Javascript Buffered Undo Manager

This library provides a simple undo manager with update buffering
to avoid a scenario where undos become data-intensive or cumbersome
for the user in scenarios with fast-changing content.

## Requirements

As of now BufferedUndoManager requires both jQuery and Underscore.

## Usage

The usage of the BufferedUndoManager is straightforward:

```javascript
var manager = new BufferedUndoManager();

manager.update("first");
manager.update("second");
manager.state; // "second"
manager.undo(); 
manager.state; // "first"
manager.redo();
manager.state; // "second"

// What if we have frequent updates, such as a keyup?
manager.update("t");
manager.update("th");
manager.update("thi");
manager.update("thir");
manager.update("third");
manager.state; // "third"
manager.undo();
manager.state; // "second"

// Pass the force option to trigger an update regardless of
// speed.
manager.update("t", {force: true});
manager.update("th");
manager.undo();
manager.state; // "t"
```

By default the manager will buffer input for one second (the input must
become idle for one second before another entry will be created).

## Demo

You can see a [simple example](http://divshot.github.com/buffered_undo_manager/example.html) of how the library works.

## Documentation

You can see the [Docco Docs](http://divshot.github.com/buffered_undo_manager/docs/buffered_undo_manager.html) for more in-depth API documentation.

## License

Copyright (c) 2012 Divshot

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.