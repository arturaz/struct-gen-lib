require 'node.rb'

module Structurograme  
  class If
    include Node

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
  end
end