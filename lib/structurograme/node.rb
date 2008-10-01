module Structurograme
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
end
