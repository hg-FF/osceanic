require 'date'

class DateTime
	def desamber
		return Desamber.date self
	end
end

class Desamber
	def self.date date
		doty = date.yday
		y = date.year.to_s[2,4]
		m = ((97 + (doty/14)).chr).capitalize
		m = doty == 365 || doty == 366 ? "+" : m
		d = doty % 14
		d = d < 10 ? "0#{d}" : d
		d = d == "00" ? "14" : d
		d = doty == 365 ? "01" : (doty == 366 ? "02" : d)
		"#{y}#{m}#{d}"
	end

	def self.to_date str
		y = ("20" + str[0,2]).to_i
		m = str[2,1]
		d = str[3,2]

		mt = ((m.ord)-('A'.ord))
		DateTime.ordinal(y, 14*mt + d.to_i)
	end

	def self.time time
		msm = time.to_time.to_f - Date.today.to_time.to_f 
		val = msm / 8640 / 10000
		m = val.round(12).to_s[5,6]
		m[0,3]+":"+m[3,3]
	end
end