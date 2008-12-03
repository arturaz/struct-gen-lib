$LOAD_PATH.push File.dirname(__FILE__)
require 'block.rb'

class Structurograme
  # Represents call clauses.
  class Call < Block
    # Left and right margin.
    def margin
      margin = 5
      margin += padding if padding
      margin
    end

    # Same as super#render_at but add two lines at left and right sides.
    def render_at(x, y)
      super(x, y)
      x, x_end = x

      draw.rectangle(
        x, y,
        x_end, y + height
      )
      true
    end
  end
end
