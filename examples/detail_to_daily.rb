# This example will take a Heure log and output an Journalée log
# The Journalée log format is based in the Horaire format.

require_relative '../tablatal.rb'
require_relative '../indental.rb'
require_relative '../runic.rb'
require_relative '../desamber.rb'
require 'pp'

table = "
DATE  CODE TERM               DESC                                                   END
"
f_date = "%5s"   
f_code = "%4s"
f_term = "%17s" 
f_desc = "%54s"

detail = "
18N01
	one
		code : 397
		term : Dépôt
		desc : Do some touches to the Dépôt styling
	two
		code : 347
		term : Osceanic
		desc : Start porting Oscean formats to Ruby
18N02
	one
		code : 329
		term : Osceanic
		desc : Finish porting all formats
"

det = Indental.parse(detail)

det.each do |date, content|
	p = []
	k = []
	content.each do |key, terms|
		sector = terms[:code][0].to_i
		value = terms[:code][1].to_i
		vector = terms[:code][2].to_i

		k.push key
		p.push value
	end
	i = k[p.index(p.max)]
	table += "#{sprintf(f_date, date)} #{sprintf(f_code, content[i][:code])}  #{sprintf(f_term, content[i][:term])} #{sprintf(f_desc, content[i][:desc])}\n"
end

puts table
pp Tablatal.parse(table)