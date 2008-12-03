require 'node.rb'

class Structurograme
  # Class representing block clauses.
  class Block < String # {{{
    include Node

    def initialize(content)
      super(content || "")
    end

    # Override this method to change left and right margins. Defaults to 0.
    def margin; 0; end

    # Return text wrapped into width.
    def boxed_text
      left, right = x_boundaries
      super(to_s, right - left - 2 * (margin + padding))
    end
    
    # Return height of the element.
    def height
      if self == ""
        @height ||= 3 * char_height
      else
        @height ||= draw.get_multiline_type_metrics(boxed_text).height + padding
      end
    end
    
    # Render Block @ _x_, _y_.
    def render_at(x, y)
      x, x_end = x
      
      unless self == ""
        text = boxed_text
        draw.text(x + margin + padding, y_start_for_text(y, text), text)
      end

      draw.rectangle(
        x + margin, y,
        x_end - margin, y + height
      )
      
      true
    end
  end # }}}
end