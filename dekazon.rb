require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'

WISHLIST_URL = 'http://www.amazon.com/wishlist/2OB50ZPAG5P09/ref=cm_wl_act_print_o?_encoding=UTF8&layout=standard-print&disableNav=1&visitor-view=1&items-per-page=200&page=1'

puts 'Fetching Amazon wishlist...'
amazon_doc = Nokogiri::HTML(open(WISHLIST_URL))
titles = amazon_doc.css('div.pTitle strong').map { |el| el.content }

def search_url_for_title(title)
  term = CGI.escape title
  url = "http://dekalb.ipac.sirsidynix.net/ipac20/ipac.jsp?menu=search&profile=dcpl&term=#{term}&index=.TW"
  url
end

puts "Searching library for #{titles.size} titles..."
STDOUT.sync = true  # unbuffered I/O, since we are skipping newlines
results = titles.map do |title|
  url = search_url_for_title title
  search_doc = Nokogiri::HTML(open(url))
  el = search_doc.css('a.mediumBoldAnchor').first
  count = el ? el.content.to_i : 0

  if count > 0 then
    print "\n#{title}: #{count} found\n" if count > 0
  else
    print '.'
  end

  [title, count]
end

sorted = results.select { |p| p.last > 0 }.sort_by { |p| p.last }
puts "Found #{sorted.size} titles with results:"
sorted.map do |p|
  puts " - #{p.first} (#{p.last})"
end
0
