class RunicStash
	def initialize
		@rune = ""
		@all = []
	end

	def add(rune, item)
		@rune = self.copy(rune)
		@all.push({rune: rune, item: item})
	end

	def pop
		copy = self.copy(@all)
		@all = []
		copy
	end

	def is_pop rune
		@all.size > 0 && rune[:tag] != @rune[:tag]
	end

	def length
		@all.length
	end

	def copy data
		Marshal.load(Marshal.dump(data))
	end

	def render
		rune = @rune
		stash = self.pop
		html = ""
		stash.each do |element|
			rune = element[:rune]
			line = element[:item]

			html += rune[:wrap] ? "<#{rune[:sub]}><#{rune[:wrap]}>#{line.gsub(/\|/, "</#{rune[:wrap]}><#{rune[:wrap]}>").strip}</#{rune[:wrap]}></#{rune[:sub]}>" : "<#{rune[:sub]}>#{line}</#{rune[:sub]}>"
		end

		"<#{rune[:tag]} class='#{rune[:class]}'>#{html}</#{rune[:tag]}>"
	end
end

class Markup
	def self.parse text
		text = text.gsub(/{_/, "<i>").gsub(/_}/, "</i>")
		text = text.gsub(/{\*/, "<b>").gsub(/\*}/, "</b>")
		text = text.gsub(/{\#/, "<code class='inline'>").gsub(/\#}/, "</code>")

		parts = text.split("{{")
		parts.each do |part|
			next if part.index('}}') == nil
			content = part.split('}}')[0]
			if content[0] == "/"
				text = text.gsub("{{#{content}}}", eval(content.gsub("/", "")))
				next
			end
			target = content.index("|") != nil ? content.split("|")[1] : content
			name = content.index("|") != nil ? content.split("|")[0] : content
			external = (target.index("https:") != nil || target.index("http:") != nil || target.index("dat:") != nil)
			text = text.gsub("{{#{content}}}", external ? "<a href='#{target}' class='external' target='_blank'>#{name}</a>" : "<a class='local' href='/#{target.downcase}'>#{name}</a>")
		end

		text
	end
end

class Runic
	def self.runes
		{
			"&": {glyph: "&", tag: "p", class: ""},
			"~": {glyph: "~", tag: "list", sub: "ln", class: "parent", stash: true},
			"-": {glyph: "-", tag: "list", sub: "ln", class: "", stash: true},
			"=": {glyph: "~", tag: "list", sub: "ln", class: "mini", stash: true},
			"!": {glyph: "!", tag: "table", sub: "tr", wrap: "th", class: "outline", stash: true},
			"|": {glyph: "|", tag: "table", sub: "tr", wrap: "th", class: "outline", stash: true},
			"#": {glyph: "#", tag: "code", sub: "ln", class: "", stash: true},
			"%": {glyph: "%"},
			"?": {glyph: "?", tag: "note", class: ""},
			":": {glyph: ":", tag: "info", class: ""},
			"*": {glyph: "*", tag: "h2", class: ""},
			"+": {glyph: "+", tag: "hs", class: ""},
			"@": {glyph: "@", tag: "quote", class: ""},
			"/": {glyph: "/", tag: "", class: ""},
		}
	end

	@@stash = ::RunicStash.new

	def self.parse string
		html = ""
		lines = string.strip.split("\n")

		lines.each do |line|
			char = line.strip[0]
			rune = Runic.runes[char.to_sym]
			trail = line[1]
			lin = line[2, line.length - 1]

			if char == "/"
				html += "<p>#{eval(lin)}</p>"
				next
			end

			if char == "%"
				html += Runic.media(lin)
				next
			end

			if char == "@"
				html += Runic.quote(lin)
				next
			end

			line = Markup.parse(line)
			
			next if line == nil || line.strip == ""
			if rune == nil
				warn "Unknown rune: '#{char}'|'#{line}'"
				next
			end

			if trail != " "
				warn "Non-rune[#{trail}] in '#{line}'"
				next
			end

			if @@stash.is_pop(rune)
				html += @@stash.render
			end

			if rune[:stash] == true
				@@stash.add(rune, lin)
				next
			end

			html += Runic.render(lin, rune)
		end

		if @@stash.length > 0
			html += @@stash.render
		end

		html
	end

	def self.media val
		service = val.split(" ")[0]
		id = val.split(" ")[1]

		return %Q(<iframe frameborder="0" src="https://itch.io/embed/#{id}?link_color=000000" width="600" height="167"></iframe>) if service == "itchio"
		return %Q(<iframe style="border: 0; width: 600px; height: 274px;" src="https://bandcamp.com/EmbeddedPlayer/album=#{id}/size=large/bgcol=ffffff/linkcol=333333/artwork=small/transparent=true/" seamless></iframe>) if service == "bandcamp"
		return %Q(<iframe width="600" height="315" src="https://www.youtube.com/embed/#{id}" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>) if service == "youtube"
		return %Q(<iframe src="#{id}" style="width:100%;height:350px;"></iframe>) if service == "custom"
	end

	def self.quote val
		text, author, source, link = val.split(" | ")
		"<quote><p class='text'>#{Markup.parse(text)}</p><p class='attrib'>#{author}#{source && link ? ", <a href='#{link}'>#{source}</a>" : source ? ", <b>#{source}</b>" : ''}</p></quote>"
	end

	def self.render line, rune
		return "<img src='/media/#{line}'/>" if rune[:tag] == "img"
		return "HEY" if rune[:tag] == "table"
		rune[:tag] ? "<#{rune[:tag]} class='#{rune[:class]}'>#{line}</#{rune[:tag]}>" : line
	end
end