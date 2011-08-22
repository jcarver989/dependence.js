Dependence.js
====================
Dependence.js is a ruby gem for managing large CoffeeScript and/or Javascript projects. Depedendence helps you manage file
dependences and separates your javascript code into clean independent modules. 

Example
---------------------
Suppose we have some javascript project with the following directory structure:

* src/
  - share_widget 
      + dom_bindings.js
      + events.js
      + animations.js
      + component_1.js
      + component_2.js

  - popup_widget
      + frame.js
      + animations.js
      + configuration.js



In our share_widget directory suppose that component_1.js and component_2.js each depenend on events.js, dom_bindings.js and animations.js
Again suppose that animations.js depends on dom_bindings.js and you can see how managing these dependencies quickly gets very messy. 



* require statement //@import foo.js (relative path from the source file)
* each directory becomes a module
* modularize code with exports object
* compiler coffeescript
* closure compiler to compress/minify/optimize code


