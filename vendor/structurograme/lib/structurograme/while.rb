require 'holder.rb'

class Structurograme
  class While < Holder
    attr_accessor :clause

    def initialize(node)
      @clause = (node['clause'] || node['c'] || "").strip
      replace Structurograme.parse(node, :parent => self)
    end
    
    def boxed_text
      left, right = x_boundaries
      super(@clause, right - left - 2 * padding - char_width)
    end
    
    def height
      @height ||= @clause.blank? ? 0 : clause_height + super
    end
    
    def clause_height
      @clause_height ||= draw.get_multiline_type_metrics(boxed_text).height +
        padding
    end

    def render_at(x, y)
      x, x_end = x

      # Clause
      unless @clause.blank?
        text = boxed_text
        draw.text(x + padding + 2 * char_width, y_start_for_text(y, text), text)
      end

      # Inner elements
      x_inner = x + padding + char_width
      x_inner_end = x_end
      y_inner = y + clause_height
      super([x_inner, x_inner_end], y_inner)

      # Inner border
      draw.rectangle(
        x_inner, y_inner,
        x_inner_end, y + height
      )

      # Element border
      draw.rectangle(
        x, y,
        x_end, y + height
      )
    end
  end
end