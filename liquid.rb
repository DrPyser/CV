require 'liquid'
require 'json'

template_filename = ARGV[0]
context_filename = ARGV[1]
if template_filename == "-"
  template = STDIN.read()
else
  template = File.read(template_filename)
end

if context_filename == "-"
  context = JSON.parse(STDIN.read())
elsif context_filename == nil
  context = {}
else
  context = JSON.parse(File.read(context_filename))
end

templated = Liquid::Template.parse(template)
puts templated.render(context)

