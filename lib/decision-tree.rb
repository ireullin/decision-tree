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


module DecisionTree
    def self.train(entries, **arg)
        algorithm = arg[:algorithm] || 'c45'
        Node.new(entries, arg[:columns], algorithm)
    end


	class Node
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
	            # buff << "#{indent}if(#{feature_index} == #{feature_value}){"
	            child_node.to_pseudo_code(buff, indent+"  " )
	            buff << "#{indent}}"
	        end
	        return buff
	    end


	    def predict(vector, default=nil)
	    	if @child_nodes.size==0
	    		probability = Hash.new(0)
	    		@labels.each{|k| probability[k] += 1 }
	    		probability.each{|k,v| probability[k] = v / @labels.size.to_f }
	    		return probability.to_json
	    	else
	    		feature_value = vector[feature_index]
	    		return default if not @child_nodes.has_key?(feature_value)
		    	return @child_nodes[feature_value].predict(vector)
		    end
	    end

	    private
		def choose_best_feature(entries)

			labels = entries.map{|x| x[:label]}

			max_ig = {index: -1, ig: -1.0}
			@dimension.times do |i|
				next if @path.include?(i)
				child_entropy = entries.map{|x| x[:features][i]}.concitional_entropy_with(labels)
				
	            ig = if @algorithm=='id3'
	                @entropy - child_entropy
	            else# c45
	                a = (@entropy - child_entropy)
	                b = entries.map{|x| x[:features][i]}.entropy
	                # puts "@path=#{@path}"
	                # puts "i=#{i} @entropy=#{@entropy} child_entropy=#{child_entropy} a=#{a} b=#{b}"
	                gain = (@entropy - child_entropy) / entries.map{|x| x[:features][i]}.entropy
	                gain = 0 if gain.nan?
	                gain
	            end

	            max_ig = {index: i, ig: ig} if ig > max_ig[:ig]
	            # puts "max_ig=#{max_ig} ig=#{ig}"
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
				@child_nodes[feature_value] = Node.new(child_entries, @columns, @algorithm, @dimension, self, feature_value, @path.dup)
			end
		end
	end
end