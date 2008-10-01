require 'holder.rb'

module Structurograme
  class While < Holder
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
  end
end