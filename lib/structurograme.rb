#!/usr/bin/env ruby
# vim:softtabstop=2
# vim:tabstop=2
# vim:shiftwidth=2
#
# @author Artūras Šlajus <x11@arturaz.net>
# @license http://creativecommons.org/licenses/LGPL/2.1/ CC-GNU LGPL

require 'xml/libxml'
require 'GD'
require 'structurograme/node.rb'
require 'structurograme/holder.rb'
require 'structurograme/block.rb'
require 'structurograme/call.rb'
require 'structurograme/if.rb'
require 'structurograme/while.rb'

class Structurograme  
  # Exception to be raised if we're trying to give not XML node.
  class NotXMLNodeException < Exception; end

  include Node

  # Parses _node_ into _Structurograme::Holder_
  def self.parse(node)
    # Node must be XML::Node
    self.xml_node_check! node

    h = Structurograme::Holder.new
    self.each_child(node) do |child|
      child_name = child.name.to_sym
      
      case child_name
      when :b, :block, :c, :call
        text_node = child.child
        content = text_node.nil? ? "" : text_node.content

        case child_name
        when :b, :block
          h.push Structurograme::Block.new(content)
        when :c, :call
          h.push Structurograme::Call.new(content)
        end
      when :i, :if
        h.push Structurograme::If.new(child)
      when :w, :while
        h.push Structurograme::While.new(child)
      end
    end
    
    h
  end
  
  # Iterator that yields every child in _node_.
  def self.each_child(node)
    # Node must be XML::Node
    self.xml_node_check! node

    if node.child?
      child = node.child
      yield child
      
      while child.next?
        child = child.next
        yield child
      end
    end

    children
  end

  # Raises exception if _node_ is not XML::Node
  def self.xml_node_check!(node)
    raise Structurograme::NotXMLNodeException unless node.is_a? XML::Node
  end

  # Wraps text
  def self.wrap_text(text, len = 80)
    text.to_a.collect do |line|
      t = []
      1.upto((Float(line.length) / len).ceil) do |i|
        # Arithmetical progression
        # a = (n - 1) * q
        t.push line[( (i - 1) * len )..( (i - 1) * len + len - 1)]
      end
      t.join("\n")
    end.join
  end

  def initialize(node, font, size=12, width=600)
    # Some constants
    @color = {
      'white' => GD::Image.trueColor("#FFFFFF"),
      'black' => GD::Image.trueColor("#000000")
    }
    @font = font
    @size = size.to_i
    @width = width.to_i
    @padding = (@size * 0.85).to_i

    # Let's find out how wide one char is.
    @char_width = @size * 0.8
    @char_height = @size

    @data = self.class.parse(node)
    @data.parent = self
  end

  def height
    # Render in a fake run ;-)
    x, y = @data.render_at(
      # x_start, x_end
      [@padding + 1, @width - @padding - 1],
      # y_start
      @padding + 1,
      true
    )
    # 1 for border, 1 for spare space
    y + 2
  end

  def render
    @img = GD::Image.newTrueColor(@width + 2, height + @padding)
    @img.fill(0, 0, color('white'))
    
    @data.render_at(
      [@padding + 1, @width - @padding - 1],
      @padding + 1
    )

    @img.pngStr
  end
end