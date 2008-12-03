class Structurograme
  module Node  
    # Makes attributes in _args_ to be accessed from _@parent_. If
    # _@parent_ is nil (current _Node_ is the root node) then return
    # _@arg_. See Node#get_from_root_node for more.
    #
    # P.S.: Thanks Aria from #ruby-lang on freenode ;-)
    def self.attr_from_root_node(*args)
      args.each do |arg|
        define_method(arg) do
          get_from_root_node(arg)
        end
      end
    end
    
    attr_from_root_node :font_path, :font_size, :font, \
      :width, :indent, :padding, \
      :char_width, :char_height, :image, :draw, :x_boundaries
    attr_accessor :parent

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

    # Compute Y coordinate where text starts for given _text_ and _y_.
    #
    # We need this, because #char_height needs to be appended (because 
    # coords for text starts at bottomleft of first line)
    def y_start_for_text(y, text)
      y + padding + (text.blank? ? 0 : char_height) + 2
    end

    # Rewrap _text_ so it would fit into a box. 
    def boxed_text(text, text_width)      
      Structurograme.wrap_text(
        text.strip,
        (text_width.to_f / char_width).floor
      )
    end
  end
end
