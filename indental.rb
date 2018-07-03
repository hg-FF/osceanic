require 'pp'

class Indental
	def self.parse string, indent = 1
		_lines = string.strip().split("\n")
		lines = []
		_lines.each do |line|
			lines.push Indental.liner(line)
		end
		
		stack = {}
		target = lines[0]

		if indent == "\t" then indent = 1 end

		lines.each do |line|
			if line[:skip] then next end
			target = stack[line[:indent] - indent]
			if target != nil then target[:children].push(line) end
			stack[line[:indent]] = line
		end
		
		h = {}

		lines.each do |line|
			if line[:skip] || line[:indent] > 0 then next end
			key = line[:content]
			h[key.to_sym] = Indental.format(line)
		end

		h
	end

	def self.format line
		a = []
		h = {}

		line[:children].each do |child|
			if child[:key] != nil
				h[child[:key].to_sym] = child[:value] 
			elsif child[:children].length == 0 && child[:content] != nil 
				a.push child[:content]
			else
				h[child[:content].to_sym] = Indental.format(child)
			end
		end

		return a.length > 0 ? a : h
	end

	def self.liner line
		{
			indent: line.match(/^\s*/).to_s.size,
			content: line.strip,
			skip: line == "" || line[0] == "~",
			key: line.index(" : ") != nil ? line.split(" : ")[0].strip : nil,
			value: line.index(" : ") != nil ? line.split(" : ")[1].strip : nil,
			children: []
		}
	end
end