class Enemy
  SPEED = 2
  def initialize(window)
    @radius = 16
    @y = 0
    @x = rand(window.width - 2 * @radius) + @radius
    @image = Gosu::Image.new('images/enemy.png')
    # @window = window
  end

  def draw
    @image.draw(@x - @radius, @y - @radius, 1)
  end

  def move
    @y += SPEED
  end
end
