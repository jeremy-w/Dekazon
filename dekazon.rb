require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'

# This is the URL of the printable version of my wishlist.
WISHLIST_URL = 'http://www.amazon.com/wishlist/2OB50ZPAG5P09/ref=cm_wl_act_print_o?_encoding=UTF8&layout=standard-print&disableNav=1&visitor-view=1&items-per-page=200&page=1'

puts 'Fetching Amazon wishlist...'
amazon_doc = Nokogiri::HTML(open(WISHLIST_URL))
# The element we're looking at here is like:
#    <div class="pTitle">
#    <strong>The Intelligent Investor: The Classic Text on Value Investing</strong>
#    <span class="small itemByline"> by Benjamin Graham, Jason Zweig</span>
#    </div>
titles = amazon_doc.css('div.pTitle strong').map { |el| el.content }
puts "#{titles.count} titles found."

# Generates the url string corresponding to a search for +title+.
def library_search_url_for_title(title)
  term = CGI.escape title
  url = "http://dekalb.ipac.sirsidynix.net/ipac20/ipac.jsp?menu=search&profile=dcpl&term=#{term}&index=.TW"
  url
end

# Returns the result count of +doc+.
def library_search_result_count(doc)
  # This corresponds to the 7 in
  #    <a class="normalBlackFont2"><b>7</b> titles matched:...</a>
  el = doc.css('a.normalBlackFont2 b').first
  count = el ? el.content.to_i : 0
end

# Returns an array of the titles found.
def library_search_result_titles(doc)
  results = doc.css('a.mediumBoldAnchor').map { |el| el.content }
end

puts "Searching library for #{titles.size} titles..."
# Force unbuffered I/O. stdout to terminal flushes on newlines,
# but when no result is found, we just print a dot without any newline.
STDOUT.sync = true
i = 0
results = titles.map do |title|
  url = library_search_url_for_title title
  doc = Nokogiri::HTML(open(url))
  count = library_search_result_count doc

  i += 1
  msg = (count > 0) ? "\n#{title}: #{count} found\n" : "#{i}."
  print msg

  [title, count]
end
puts

sorted = results.select { |p| p.last > 0 }.sort_by { |p| p.last }
puts "Found #{sorted.size} titles with results:"
sorted.map do |p|
  puts " - #{p.first} (#{p.last} results)"
end
0
