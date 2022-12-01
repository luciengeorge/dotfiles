begin
  require 'rubygems'
  require 'pry'
rescue LoadError
end

if defined?(Pry)
  Pry.start
  exit
end

IRB.conf[:USE_AUTOCOMPLETE] = false
