require './decision-tree.rb'
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


root = DecisionTree.train(data, algorithm:'c45', columns:['feature1','feature2','feature3','feature4'])
root.to_pseudo_code.each{|line| puts line}
