#!/usr/bin/env ruby
# vim:softtabstop=2
# vim:tabstop=2
# vim:shiftwidth=2
#
# @author Artūras Šlajus <x11@arturaz.net>
# @license http://creativecommons.org/licenses/LGPL/2.1/ CC-GNU LGPL

class Structurograme
  require 'xml/libxml'
  require 'GD'

  module Node
  
    # Makes attributes in _args_ to be accessed from _@parent_. If
    # _@parent_ is nil (current _Node_ is the root node) then return
    # _@arg_. See Node#get_from_root_node for more.
    #
    # P.S.: Thanks Aria from #ruby-lang on freenode ;-)
    def self.attr_from_root_node(*args)
      args.each do |arg|
        define_method(arg) do
          get_from_root_node("#{arg}")
        end
      end
    end
    
    attr_from_root_node :font, :size, :width, :indent, :char_width, \
      :char_height, :padding, :img
    attr_accessor :parent
    
    # Return _Node_ color.
    def color(key)
      get_from_root_node('color', key)
    end

    # Get attribute _attr_ from the root node.
    def get_from_root_node(attr, key=nil)
      if @parent.nil?
        v = instance_variable_get("@#{attr}")
        if key.nil?
          v
        else
          v[key]
        end
      else
        @parent.get_from_root_node(attr, key)
      end
    end
    
    # Return according #stringTTF method depending if it's _fake_run_ or not.
    # If it's fake then nothing is actually rendered on the image.
    def get_stringTTF(fake_run)
      if fake_run
        stringTTF = GD::Image.method(:stringTTF)
      else
        stringTTF = img.method(:stringTTF)
      end
      stringTTF
    end

    # Compute Y coordinate where text starts for given _text_ and _y_.
    #
    # We need this, because char_height needs to be appended (because 
    # coords for stringTTF starts at bottomleft of first line)
    def y_start_for_text(y, text)
      y_start = y + padding
      y_start += char_height if text != ""
    end

    # Rewrap _text_ so it would fit into a box. 
    def boxed_text(text, text_width)
      # Text that fits into the box! ;-)
      code_started = false
      text = text.rstrip.to_a.collect do |line|
        if code_started or line.strip != ""
          code_started = true
          line
        end
      end.join
      
      Structurograme.wrap_text(
        text,
        (Float(text_width) / Float(char_width)).floor
      )
    end
  end

  # Exception to be raised if we're trying to give not XML node.
  class NotXMLNodeException < Exception; end

  include Structurograme::Node

  # Parses _node_ into Structurograme::Holder
  def self.parse(node)
    # Node must be XML::Node
    self.xml_node_check! node

    h = Structurograme::Holder.new
    self.get_children(node).each do |child|
      child_name = child.name.to_sym
      if [:b, :block, :c, :call].include? child_name
        if child.child.nil?
          content = ""
        else
          content = child.child.content
        end

        if [:b, :block].include? child_name
          h.push Structurograme::Block.new(content)
        elsif [:c, :call].include? child_name
          h.push Structurograme::Call.new(content)
        end
      elsif [:i, :if].include? child_name
        h.push Structurograme::If.new(child)
      elsif [:w, :while].include? child_name
        h.push Structurograme::While.new(child)
      end
    end
    
    h
  end
  
  # Returns Array of _node_ children
  def self.get_children(node)
    # Node must be XML::Node
    self.xml_node_check! node

    children = []
    if node.child?
      c = node.child
      children.push c
      while c.next?
        c = c.next
        children.push c
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

# Simple class that extends _Array_ for holding other elements in 
# _Structurograme_. This acts as _Node_.
class Structurograme::Holder < Array #{{{
  include Structurograme::Node

  alias old_push push  
  # Add a node to holder. Also assign _self_ as parent to _node_ if it 
  # supports it.
  def push(node)
    node.parent = self if node.respond_to? 'parent'
    old_push(node)
  end

  # Render all nodes that we're holding and return end coordinates: [x, y].
  def render_at(x, y, fake_run=false)
    each do |node|
      x, y = node.render_at(x, y, fake_run)
    end
    [x, y]
  end
end # }}}

# Class representing block clauses.
class Structurograme::Block < String # {{{
  include Structurograme::Node

  def initialize(content)
    content ||= ""
    super(content)
  end

  # Override this method to change left and right margins. Defaults to 0.
  def margin; 0; end

  def render_at(x, y, fake_run=false)
    x, x_end = x
    
    text = boxed_text(to_s, x_end - x - 2 * margin - 2 * padding)
    if text == ""
      y_end = y + 3 * char_height
    else
      y_start = y_start_for_text(y, text)

      err, brect = get_stringTTF(fake_run).call(
        color('black'), font, size, 0,
        x + margin + padding, y_start,
        text
      )
      y_end = brect[1] + padding
    end
    
    if not fake_run
      img.rectangle(
        x + margin, y,
        x_end - margin, y_end,
        color('black')
      )
    end

    [[x, x_end], y_end]
  end
end # }}}

# Represents call clauses.
class Structurograme::Call < Structurograme::Block # {{{
  # Left and right margin.
  def margin
    margin = 5
    margin += padding if padding
    margin
  end

  # Same as super#render_at but add two lines at left and right sides.
  def render_at(x, y, fake_run=false)
    x, y_end = super(x, y, fake_run)
    x, x_end = x

    if not fake_run
      img.rectangle(
        x, y,
        x_end, y_end,
        color('black')
      )
    end
    [[x, x_end], y_end] 
  end
end # }}}

class Structurograme::If # {{{
  include Structurograme::Node

  attr_accessor :clause, :true, :false, :ratio

  def initialize(node)
    @clause = node['clause'] || node['c'] || ""

    true_width = nil
    false_width = nil
    Structurograme.get_children(node).each do |child|
      if child.name == "true"
        @true = Structurograme.parse(child)
        true_width = child['width']
        @true.parent = self
      elsif child.name == "false"
        @false = Structurograme.parse(child)
        false_width = child['width']
        @false.parent = self
      end
    end

    if true_width
      @ratio = true_width.to_i
    elsif false_width
      @ratio = 100 - false_width.to_i
    else  
      @ratio = nil
    end
  end

  def render_at(x, y, fake_run=false)
    x, x_end = x
    
    # Clause
    text = boxed_text(@clause, x_end - x - 2 * padding - 12 * char_width)
    if text == ""
      y_clause_end = y + 3 * char_height
    else
      y_start = y_start_for_text(y, text)

      err, brect = get_stringTTF(fake_run).call(
        color('black'), font, size, 0,
        x + padding + 6 * char_width, y_start,
        text
      )
      y_clause_end = brect[1] + padding  
    end
    
    if not fake_run
      # Clause border
      img.rectangle(
        x, y,
        x_end, y_clause_end,
        color('black')
      )
    
      # True
      text = "T"
      y_start = y_start_for_text(y, text)

      err, brect = get_stringTTF(fake_run).call(
        color('black'), font, size, 0,
        x + padding, y_start,
        text
      )
      img.line(
        x, y,
        x + padding + 6 * char_width, y_clause_end,
        color('black')
      )

      # False
      text = "N"
      y_start = y_start_for_text(y, text)

      err, brect = get_stringTTF(fake_run).call(
        color('black'), font, size, 0,
        x_end - padding - char_width, y_start,
        text
      )
      img.line(
        x_end, y,
        x_end - padding - 6 * char_width, y_clause_end,
        color('black')
      )
    end

    # Middle line
    if @ratio.nil?
      if @true and not @false
        x_middle = x_end - 7 * char_width
      elsif @false and not @true
        x_middle = x + 7 * char_width
      else
        x_middle = Float(x + x_end) / 2
      end
    else
      x_middle = x + (Float(x_end - x) * @ratio / 100)
    end

    if @true
      x_true, y_true = @true.render_at(
        [x, x_middle], y_clause_end,
        fake_run
      )
    else
      y_true = y_clause_end
    end

    if @false
      x_false, y_false = @false.render_at(
        [x_middle, x_end], y_clause_end,
        fake_run
      )
    else
      y_false = y_clause_end
    end

    y_end = [y_true, y_false].max

    # Inner border
    if not fake_run
      img.rectangle(
        x, y,
        x_end, y_end,
        color('black')
      )
    end
    
    [[x, x_end], y_end]
  end
end # }}}

class Structurograme::While < Structurograme::Holder # {{{
  attr_accessor :clause
    
  def initialize(node)
    @clause = node['clause'] || node['c'] || ""
    children = Structurograme.parse(node)
    children.parent = self
    replace children
  end

  def render_at(x, y, fake_run=false)
    x, x_end = x

    # Clause
    text = boxed_text(@clause, x_end - x - 2 * padding - char_width)
    if text == ""
      y_end = y
    else
      y_start = y_start_for_text(y, text)

      err, brect = get_stringTTF(fake_run).call(
        color('black'), font, size, 0,
        x + padding + 2 * char_width, y_start,
        text
      )
      y_end = brect[1] + padding
    end

    # Inner elements
    x_inner = x + padding + char_width
    x_inner_end = x_end
    y_inner = y_end
    x_inner, y_inner_end = super([x_inner, x_inner_end], y_inner, fake_run)
    x_inner, x_inner_end = x_inner

    if not fake_run
      # Inner border
      img.rectangle(
        x_inner, y_inner,
        x_inner_end, y_inner_end,
        color('black')
      )

      # Element border
      img.rectangle(
        x, y,
        x_end, y_inner_end,
        color('black')
      )
    end

    [[x, x_end], y_inner_end]
  end
end # }}}
