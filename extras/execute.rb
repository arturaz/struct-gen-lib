#!/usr/bin/env ruby
#
# @author Artūras Šlajus <x11@arturaz.net>
# @license http://creativecommons.org/licenses/LGPL/2.1/ CC-GNU LGPL

help =<<EOF
Usage: execute.rb input_file output_file font size image_width

Arguments:
  input_file      File with XML to be parsed.
  output_file     Filename where to write PNG data.
  font            .ttf font file to be used.
  size            Font size to be used.
  image_width     Destination image width.
EOF
0.upto(4) do |i|
  if ARGV[i].nil?
    $stderr.write help
    exit
  end
end

input_fname, output_fname, font, size, width = ARGV

require 'xml/libxml'
require 'pathname'
require File.expand_path(File.dirname(__FILE__) + '/lib/structurograme.rb')

# Turn on Unicode support
$KCODE = 'u'
require 'jcode'

# Create XML document
begin
  doc = XML::Parser.string(File.read(input_fname)).parse
rescue LibXML::XML::Error => e
  puts e.message
  exit
end

# Create new structurograme
s = Structurograme.new(
  doc.root,
  Pathname.new(font).realpath.to_s,
  size,
  width
)

# Write output to file.
File.open(output_fname, 'wb') do |f|
  f.write s.render
end
