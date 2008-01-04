#!/usr/bin/ruby

STARTTIME = Time.now

# Global defines
LANG    = "fr"
RTL     = false
PROJECT = "books"
MASTER = "books"
NAMESPAC= {:id => 0, :name => nil}
UNIQID  = Time.now.to_i
UNIQFD  = "/home/reg/var/#{LANG}/#{PROJECT}_#{UNIQID}"
MDWKFD  = "/var/www/reg.kiwix.org/wiki"
DBICON  = "DBI:Mysql:reg_#{LANG}_books"
DBIUSER = "reg"
DBIPASS = "reg"
BLOCK_SIZE	= 10485760 # 10MB

require "#{LANG}_common.rb"

#INCLUDED_NS << {:raw => "Portal", :url => "Portal"}
EXCLUDED_NS << {:raw => "Transwiki", :url => "Transwiki"}
EXCLUDED_NS << {:raw => "Discussion Transwiki", :url => "Discussion_Transwiki"}

require "../crawler.rb"

hello()

puts "Duration: #{(Time.now - STARTTIME) /60} mn."
