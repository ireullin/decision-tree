require 'csv'
require 'set'
require 'json'

module Enumerable
    def entropy
        dataset = Hash.new(0)
        self.each{|x| dataset[x] += 1 }

        entropy = 0.0
        dataset.each do |k,v|
            p = v.to_f / self.size
            entropy += (-p)*Math.log2(p)
        end

        return entropy
    end

    def concitional_entropy_with(label)
        dataset = Hash.new{|h,k| h[k] = Array.new }
        self.each_with_index{|v,i| dataset[v] << label[i] }

        new_entropy = 0.0
        dataset.each{|k,v| new_entropy += (v.size.to_f / self.size)*v.entropy }
        return new_entropy
    end
end


def read_sample
    buff = []
    File.open('sample.csv','r') do |f|
        f.each do |line|
            cells = line.chomp.split(',')
            buff << { features: cells[1..-1], label: cells[0]}
        end
    end
    return buff
end


def transpose(m)
    t = Array.new(m[0].size){Array.new(m.size)}
    m.size.times do |i|
        m[0].size.times do |j|
            t[j][i] = m[i][j]
        end
    end
    return t
end


def simpler_sample2
    return [
       	{features: [0,0,0,0],label: 'n'},
		{features: [0,0,0,1],label: 'n'},
		{features: [1,0,0,0],label: 'y'},
		{features: [2,1,0,0],label: 'y'},
		{features: [2,2,1,0],label: 'y'},
		{features: [2,2,1,1],label: 'n'},
		{features: [1,2,1,1],label: 'y'},
    ]
end


def simpler_sample
    return [
        {features: [1,'A'], label: 'true'},
        {features: [0,'B'], label: 'false'},
        {features: [1,'A'], label: 'true'},
        {features: [0,'A'], label: 'false'},
        {features: [1,'C'], label: 'true'},
        {features: [0,'C'], label: 'true'},
        {features: [1,'B'], label: 'false'},
        {features: [0,'A'], label: 'true'},
        {features: [1,'A'], label: 'true'},
        {features: [1,'C'], label: 'true'}
     ]
end


class TreeNode
	def initialize(entries, columns=nil, algorithm='c45', dimension=nil, parent_node=nil, threshold=nil, path=nil)
		@parent_node = parent_node
		@path = if path.nil?
			Array.new
		else
			path
		end

        @threshold = threshold

        @algorithm = if algorithm=='c45' or algorithm=='id3'
            algorithm
        else
            raise "Unknown algorithm"
        end

		@dimension = if dimension.nil?
			entries[0][:features].size
		else
			dimension
		end

		@columns = if columns.nil?
			@dimension.times.map{|i| "feature_#{i}"}
		elsif columns.size != @dimension
			raise "The number of columns is incorrect"
		else
			columns
		end


		@labels = entries.map{|x| x[:label]}
		@entropy = @labels.entropy
		@child_nodes = Hash.new

		return if @path.size == @dimension
		return if @entropy==0.0

		@path << choose_best_feature(entries)

		build_child_nodes(entries)
	end


	def feature_index
		@path[-1]
	end


	def feature_name
		@columns[ @path[-1] ]
	end

    def to_pseudo_code(buff=nil,indent="")
        buff = Array.new if buff.nil?

        if @child_nodes.size==0
            result = @labels.to_set.to_a
            if result.size==1
                buff << "#{indent}return #{result[0]}"
            else
                buff << "#{indent}return #{@labels}"
            end
        end

        @child_nodes.each do |feature_value,child_node|
            buff << "#{indent}if(#{feature_name} == #{feature_value}){"
            child_node.to_pseudo_code(buff, indent+"  " )
            buff << "#{indent}}"
        end
        return buff
    end

    private
	def choose_best_feature(entries)

		labels = entries.map{|x| x[:label]}

		max_ig = {index: -1, ig: -1}
		@dimension.times do |i|
			next if @path.include?(i)
			child_entropy = entries.map{|x| x[:features][i]}.concitional_entropy_with(labels)

            ig = if @algorithm=='id3'
                @entropy - child_entropy
            else# c45
                (@entropy - child_entropy) / entries.map{|x| x[:features][i]}.entropy
            end

            max_ig = {index: i, ig: ig} if ig > max_ig[:ig]
		end
		return max_ig[:index]
	end


	def build_child_nodes(entries)

		buff = Hash.new{|h,feature_value| h[feature_value] = Array.new}
		entries.each do |e|
			feature_value = e[:features][feature_index]
			buff[feature_value] << e
		end

		buff.each do |feature_value,child_entries|
			@child_nodes[feature_value] = TreeNode.new(child_entries, @columns, @algorithm, @dimension, self, feature_value, @path.dup)
		end
	end
end



def main

    # data =read_sample
    # puts data[0].to_json


    data = simpler_sample2
    root = TreeNode.new(data, ['outlook','temp','hum','windy'])
    root.to_pseudo_code.each do |line|
        puts line
    end
   	# i = root.choose_best_feature
   	# puts root.split_by_feature(i).to_json



    # label = data.map{|x| x[:label]}
    # parent_entropy = label.entropy
    # puts parent_entropy

    # id3_ig1 = parent_entropy - data.map{|x| x[:features][0]}.entropy_with(label)
    # c45_ig1 = id3_ig1 / data.map{|x| x[:features][0]}.entropy

    # id3_ig2 = parent_entropy - data.map{|x| x[:features][1]}.entropy_with(label)
    # c45_ig2 = id3_ig2 / data.map{|x| x[:features][1]}.entropy
    # puts id3_ig1,id3_ig2
    # puts c45_ig1,c45_ig2


end

main if __FILE__==$0

