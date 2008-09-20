#!/usr/bin/env ruby
#
# @author Artūras Šlajus <x11@arturaz.net>
# @license http://creativecommons.org/licenses/LGPL/2.1/ CC-GNU LGPL

0.upto(5) do |i|
  if ARGV[i].nil?
    puts "Usage: execute.rb input_file output_file font size image_width padding"
    exit
  end
end

input_fname, output_fname, font, size, width, padding = ARGV

require 'xml/libxml'
require 'pathname'
doc = XML::Document.file(Pathname.new(input_fname).realpath.to_s)

require "#{File.dirname(__FILE__)}/structurograme.rb"
# Unicode support
$KCODE = 'u'
require 'jcode'

s = Structurograme.new(
  doc.root,
  Pathname.new(font).realpath.to_s,
  size,
  width,
  padding
)

f = File.new(output_fname, 'w')
f.write s.render
f.close 
