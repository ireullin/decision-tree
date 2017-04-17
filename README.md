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
require 'decision-tree'
require 'json'

data = [
    {features: [0,0,0,0],label: 'n'},
    {features: [0,0,0,1],label: 'n'},
    {features: [1,0,0,0],label: 'y'},
    {features: [2,1,0,0],label: 'y'},
    {features: [2,2,1,0],label: 'y'},
    {features: [2,2,1,1],label: 'n'},
    {features: [1,2,1,1],label: 'y'},

]


root = DecisionTree.new(data, ['feature1','feature2','feature3','feature4'])
root.to_pseudo_code.each{|line| puts line}
```
