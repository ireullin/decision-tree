# decision-tree
It's a library to implemente decision tree within ID3 & C4.5 of algorithms.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decision-tree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install decision-tree

## Usage

A simple example:

```ruby
require 'decision-tree.rb'
require 'json'

data = [
    {features: [0,0,0,0],label: 'y'},
    {features: [0,0,0,0],label: 'n'},
    {features: [0,0,0,1],label: 'n'},
    {features: [1,0,0,0],label: 'y'},
    {features: [2,1,0,0],label: 'y'},
    {features: [2,2,1,0],label: 'y'},
    {features: [2,2,1,1],label: 'n'},
    {features: [1,2,1,1],label: 'y'},

]


#root = DecisionTree.train(data)
#root = DecisionTree.train(data, columns:['col1','col2','col3','col4'])
root = DecisionTree.train(data, algorithm:'c45', columns:['col1','col2','col3','col4'])
root.to_pseudo_code.each{|line| puts line}
puts root.predict([0,0,0,0],"out of rules")
puts root.predict([2,3,1,1],"out of rules")
puts root.predict([3,3,1,1],"out of rules")
```
