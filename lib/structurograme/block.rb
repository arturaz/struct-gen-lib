require 'node.rb'

module Structurograme
  # Class representing block clauses.
  class Block < String # {{{
    include Node

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
end