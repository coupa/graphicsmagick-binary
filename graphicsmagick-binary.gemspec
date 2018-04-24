# coding: utf-8

Gem::Specification.new do |s|
  s.name = "graphicsmagick-binary"
  s.version = "1.0.0"
  s.license = "MIT"
  s.author = "Johnny Lai"
  s.email = "johnny.lai@coupa.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides pre-built binaries for graphicsmagick (gm) in an easily-accessible package."
  s.files = Dir['bin/*']
  s.has_rdoc = false
  s.require_path = '.'
end
