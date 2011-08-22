# Wraps code in a closure that provides an exports object to attach properties to the global namespace
module ModuleInjector
  extend self

  @@module_code = <<MODULE_FUNC
var global = (global != undefined)? global : window 

if (global.module == undefined) {
  global.module = function(name, body) {
    var exports = global[name]
    if (exports == undefined) {
      global[name] = {}
    }
    body(exports)
  }
}
MODULE_FUNC

  def modularize(name, content)
    module_code = <<-JS
    #{@@module_code}

    module('#{name.capitalize}', function(exports) {
      #{content}
    })
    JS
  end
end
