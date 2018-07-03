class Tablatal
	def self.parse string
		a = []
		lines = string.strip.split("\n")
		key = Tablatal.make_key(lines[0])
		
		for i in 1..(lines.length - 1)
			entry = {}
			key.each do |ky, value|
				kf = key[ky.to_sym][:to]
				kt = key[ky.to_sym][:from]
				entry[ky] = lines[i][kt, kf]
				entry[ky] = "" if entry[ky].class == NilClass
				entry[ky].strip!
			end
			a.push entry
		end

		a
	end

	def self.make_key raw
		parts = raw.split /\ /
		for i in 0..(parts.length - 1)
			parts[i] = "" if parts[i].class == NilClass
		end 
		distance = 0
		key = {}
		prev = ""

		for i in 0..(parts.length - 1)
			part = parts[i].downcase!
			part = "" if part.class == NilClass
			if part != ""
				key[part.to_sym] = {from: distance, to: 0}
				if key[prev.to_sym] != nil
					key[prev.to_sym][:to] = distance - key[prev.to_sym][:from] - 1
				end
				prev = part
			end
			distance += (part == "" ? 1 : part.length + 1)
		end

		key
	end
end