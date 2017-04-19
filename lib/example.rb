require 'decision-tree.rb'
require 'json'

data = [
    {features: [0,"A",0,0,0.1], label: 'y'},
    {features: [0,"A",0,0,0.1], label: 'n'},
    {features: [0,"A",0,1,0.1], label: 'n'},
    {features: [1,"A",0,0,0.5], label: 'y'},
    {features: [2,"B",0,0,0.2], label: 'y'},
    {features: [2,"C",1,0,0.7], label: 'y'},
    {features: [2,"C",1,1,0.8], label: 'n'},
    {features: [1,"C",1,1,0.1], label: 'y'},

]


# Optional parameters
# algorithm: Which algorithm do you want to use? c45 or id3. Default is c45
algorithm = 'c45'

# Optional parameters
# columns: Specify name & type of your features.
#          Default names are feature1, feature2, feature3 & etc.
#          Default type is string if you don't specify.
#          If you assigned the type to num and specified the algorithm to c45,
#          the decision tree will process the feature as continuous numbers.
columns = ['col1','col2','col3','col4','col5:num']


root = DecisionTree.train(data, algorithm: algorithm, columns: columns)
root.to_pseudo_code.each{|line| puts line}
puts root.predict([0,"A",0,0,0.7])
puts root.predict([2,"C",1,1,0.5],"out of rules")
puts root.predict([3,"C",1,1,0.1],"out of rules")

