class Player
  ROTATION_SPEED = 3
  ACCELERATION = 2
  FRICTION = 0.9
  def initialize(_window)
    @x = 200
    @y = 200
    @velocity_x = 0
    @velocity_y = 0
    @angle = 0
    @image = Gosu::Image.new('images/ship.png')
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def turn_right
    @angle += ROTATION_SPEED
  end

  def turn_left
    @angle -= ROTATION_SPEED
  end

  def move
    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION
  end

  def accelerate
    @velocity_x += Gosu.offset_x(@angle, ACCELERATION)
    @velocity_y += Gosu.offset_y(@angle, ACCELERATION)
  end
end
