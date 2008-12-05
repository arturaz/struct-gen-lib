require 'node.rb'

class Structurograme  
  class If
    include Node

    attr_accessor :clause, :true, :false, :ratio

    def initialize(node)
      @clause = (node['clause'] || node['c'] || "").strip

      true_width = nil
      false_width = nil
      node.each_without(:text) do |child|
        if child.name == "true"
          @true = Structurograme.parse(child, :parent => self)
          true_width = child['width']
        elsif child.name == "false"
          @false = Structurograme.parse(child, :parent => self)
          false_width = child['width']
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
    
    def height
      if @height
        @height
      else
        @height = clause_height
        heights = []
        heights.push @true.height if @true
        heights.push @false.height if @false
        @height += heights.max
      end
    end
    
    # Height for clause
    def clause_height
      @clause_height ||= @clause.blank? ? 3 * char_height : \
        draw.get_multiline_type_metrics(boxed_text).height + padding
    end
    
    def boxed_text
      left, right = x_boundaries
      super(@clause, right - left - 2 * padding - 12 * char_width)
    end

    def render_at(x, y)
      x, x_end = x

      # Clause
      y_clause_end = y + clause_height
      unless @clause.blank?
        text = boxed_text
        draw.text(x + padding + 6 * char_width, y_start_for_text(y, text), text)
      end

      # Clause border
      draw.rectangle(
        x, y,
        x_end, y_clause_end
      )

      # True
      text = "T"
      draw.text(x + padding, y_start_for_text(y, text), text)
      draw.line(
        x, y,
        x + padding + 6 * char_width, y_clause_end
      )

      # False
      text = "N"
      draw.text(x_end - padding - char_width, y_start_for_text(y, text), text)
      draw.line(
        x_end, y,
        x_end - padding - 6 * char_width, y_clause_end
      )

      # Middle line
      if @ratio.nil?
        if @true and not @false
          x_middle = x_end - 7 * char_width
        elsif @false and not @true
          x_middle = x + 7 * char_width
        else
          x_middle = (x + x_end).to_f / 2
        end
      else
        x_middle = x + ((x_end - x).to_f * @ratio / 100)
      end

      @true.render_at([x, x_middle], y_clause_end) if @true
      @false.render_at([x_middle, x_end], y_clause_end) if @false

      # Inner border
      draw.rectangle(
        x, y,
        x_end, y + height
      )
    end
  end
end