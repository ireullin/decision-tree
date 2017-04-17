# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "decision-tree"
  spec.version       = '0.0.1'
  spec.authors       = ["ireullin"]
  spec.email         = ["ireullin@gmail.com"]
  spec.date          = '2017-04-17'
  spec.homepage      = 'https://github.com/ireullin/decision-tree'
  spec.summary       = %Q{A decision tree library which implemented ID3 & C4.5 of algorithms }
  spec.description   = %Q{A decision tree library which implemented ID3 & C4.5 of algorithms }
  spec.license       = "MIT"
  spec.files         = ['lib/decision-tree.rb']
end
