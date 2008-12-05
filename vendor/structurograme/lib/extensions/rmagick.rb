# Custom drawer.
class CustomDraw < Magick::Draw
  # Set opacity to 1 before drawing. Set fill_opactity to 0 after drawing.
  def text(*args)
    opacity(1)
    super(*args)
    fill_opacity(0)
  end
end