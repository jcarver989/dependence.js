Dependence.js
====================
Dependence.js is a ruby gem for managing large CoffeeScript or Javascript projects. Depedendence helps you manage file
dependences and separates your javascript code into clean independent modules. 

Installation 
---------------------
Just gem install dependence from rubygems.org or clone this repository and install the gem that way


Overview
---------------------
Dependence.js assumes your project is split into several independent modules (components) that are made up of one or more .js/.coffee files.
- Each module must have its own directory
- Files in a module may depend on other files in that same module, but not on files external to that module 


When you run Dependence.js it will compile all the files in each of your top level directories into a single module file.
By default the output files are wrapped in a closure that creates a property (eg. namespace) in the global space sharing the
same name as the module's directory name.

Example
---------------------
Suppose we have some javascript project with the following directory structure:

### Project Dir
* src/
  - share_widget/ 
      + dom_bindings.js
      + events.js
      + animations.js
      + component_1.js
      + component_2.js

  - popup_widget/
      + frame.js
      + animations.js
      + configuration.js

* compiled/


### Setting up the Dependencies 

animations.js

    //@import events.js

    function Animation() { ... }

    exports.Animation = Animation

component_1.js

    //@import dom_bindings.js
    //@import events.js 
    //@import animations.js 

    function Component1() { ... }

    exports.Component1 = Component1 

component_2.js

    //@import dom_bindings.js
    //@import events.js 
    //@import animations.js

    function Component2() { ... }


    exports.Component2 = Component2 

Notice the following:

- Our project is comprised of two modules: share_widget and popup_widget. 
- component_1.js and component_2.js each have module level dependencies on events.js, dom_bindings.js and animations.js while animations.js depends on events.js. These are declared with "//@import" comments - more on this below
- By default you must export any objects that you'd like to expose outside of the module


Now when we run Dependence.js:

    dependence project_dir/src/ -o compiled/

We will get two output files: share_widget.js and popup_widget.js. By default Dependence.js will wrap each output file in its own namespace (via a closure), with an object attached to the global object (window or global). This object is the capitalized name as the module's directory. So using the example above when we want to call init() on Component1 we would call it like so:

    // global namespace
    Share_widget.Component1.init()


File Dependencies
---------------------

File dependencies are declared like so in javascript

    // @import foo.js

For CoffeeScript

    # @import foo.js

File paths are relative to the widget's directory


CoffeeScript
---------------------
Dependence will automatically compile CoffeeScript (.cs or .coffee) files and Javascript (.js) files - so you can mix and match imported file types easily.

Compression/Minification
---------------------
You can have dependence minify output code as well by passing the "-c" flag (see below). This will output 2 files
per module: 1 for the uncompressed version (.js) and the compressed version (.min.js). This is done because typically
you'll want to run your unit tests/debug on the uncompressed versions


Options
---------------------
You may use the following options:
    
    dependence src_dir [options]

    -o, --output DIR             Output directory, defaults to '.' 
    -w, --watch                  Watch src_dir for changes and recompile when something changes
    -b, --bare                   Do not wrap modules in closures with exports var
    -c, --compress               Compress output with Googles Closure compiler
      






