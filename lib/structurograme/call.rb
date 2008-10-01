require 'block.rb'

module Stucturograme
  # Represents call clauses.
  class Call < Block
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
  end
end
