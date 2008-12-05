#!/usr/bin/env ruby
# vim:softtabstop=2
# vim:tabstop=2
# vim:shiftwidth=2
#
# @author Artûras Ðlajus <x11@arturaz.net>
# @license http://creativecommons.org/licenses/LGPL/2.1/ CC-GNU LGPL

$LOAD_PATH.push File.dirname(__FILE__)

require 'xml/libxml'
require 'extensions/libxml.rb'
XML::Error.set_handler(&XML::Error::QUIET_HANDLER)

require 'RMagick'
require 'extensions/rmagick.rb'
require 'activesupport'
require 'tempfile'

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
  include Magick

  # Parses _node_ into Structurograme::Holder.
  #
  # Options:
  # <tt>:parent</tt>:         set holder parent to this.
  def self.parse(node, options={})
    xml_node_check! node

    h = Holder.new
    node.each_without(:text) do |child|      
      child_name = child.name.to_sym
      
      case child_name
      when :b, :block, :c, :call
        text_node = child.child
        content = text_node.nil? ? "" : text_node.content

        case child_name
        when :b, :block
          h.push Block.new(content)
        when :c, :call
          h.push Call.new(content)
        end
      when :i, :if
        h.push If.new(child)
      when :w, :while
        h.push While.new(child)
      end
    end
    
    h.parent = options[:parent]
    h
  end

  # Raises exception if _node_ is not XML::Node
  def self.xml_node_check!(node)
    raise NotXMLNodeException unless node.is_a? LibXML::XML::Node
  end

  # Wraps _text_ to given _length_.
  def self.wrap_text(text, length=80)
    # If we're running out of space - render single space
    if length <= 0
      " "
    else
      # We need gsub to account for empty lines.
      text.scan(/.{0,#{length}}/).join("\n").gsub("\n\n", "\n")
    end
  end

  # Parse from given root node. Set default values.
  def initialize(node, font_path, font_size=12, width=600)
    @font_path = font_path
    @font_size = font_size.to_i
    @width = width.to_i
    @padding = (@font_size * 0.65).to_i
    
    @x_boundaries = [
      # Left
      @padding + 1, 
      # Right
      @width - @padding - 1
    ]

    # Let's find out how wide one char is.
    @char_width = @font_size * 0.8
    @char_height = @font_size

    @root = self.class.parse(node, :parent => self)
  end

  # Calculate image height for this structurograme.
  def height
    # 1 for border, 1 for spare space
    @root.height + @padding + 3
  end

  # Render current structurograme. Return PNG image as string.
  def render    
    @draw = CustomDraw.new
    @draw.fill('black')
    @draw.fill_opacity(0)
    @draw.stroke('black')
    @draw.stroke_width(1)
    
    @draw.font = @font_path
    @draw.pointsize = @font_size
    @draw.font_family = "Courier New"
    
    @image = Image.new(@width + 2, height + @padding) do
      self.background_color = 'white'
    end
    
    @root.render_at(
      [@padding + 1, @width - @padding - 1],
      @padding + 1
    )

    @draw.draw @image

    image_data
  end
  
  # Return image data as a string in PNG.
  def image_data
    # Store data into tempfile (with .png extension, yes imagemagick is dumb 
    # here)
    file_name = File.join(Dir::tmpdir, "structurograme-#{rand}.png")
    @image.write(file_name)
    
    # Retrieve content and delete tempfile.
    content = nil
    File.open(file_name, 'rb') { |f| content = f.read }
    File.delete(file_name)
    
    content
  end
end