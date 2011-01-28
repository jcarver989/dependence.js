#!/usr/bin/env ruby
require 'optparse'
require 'rb-inotify'
require '../lib/dependence.rb'

options = {:output => "compiled.js"}
OptionParser.new do |opts|
  opts.banner = "Usage: compile.rb js_source_dir [options]"

  opts.on("-o", "--output FILE", "Output .js file") do |file|
    options[:output] = file
  end

  opts.on("-w", "--watch", "Watch src directory for changes and recompile") do |bool|
    options[:watch] = bool
  end
end.parse(ARGV)

if ARGV.length < 1
  puts "You need to inlcude your js src directory"
  exit 1
elsif !File.directory? ARGV[0] 
  puts "Can't find your js source directory: #{ARGV[0]}"
  exit 1
end

options[:input] = ARGV[0]
compiled_file = options[:output]
File.delete(compiled_file) if File.exists?(compiled_file)

compiler = JsCompiler.new(options[:input])
compiler.compile(compiled_file)

if options[:watch]
  puts "Watching #{options[:input]} for changes your js files will be compiled automatically"
  notifier = INotify::Notifier.new
  notifier.watch(options[:input], :modify, :create, :delete) do |event|
    if event.name =~ /.js$/
      File.delete(compiled_file) if File.exists?(compiled_file)
      compiler.compile(compiled_file)
    end
  end 
  notifier.run
end




