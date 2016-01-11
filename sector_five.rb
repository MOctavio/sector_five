require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'

class SectorFive < Gosu::Window
  ENEMY_FREQUENCY = 0.02
  WIDTH = 800
  HEIGHT = 600
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @enemy_bullets = []
    @explosions = []
    @playing = true
    @msg = Gosu::Font.new(25)
  end

  def draw
    @enemies.each(&:draw)
    @bullets.each(&:draw)
    @enemy_bullets.each(&:draw)
    @explosions.each(&:draw)

    unless @playing
      @msg.draw('Game Over!', 335, 300, 3)
      @msg.draw('Press the Enter Key to Play Again', 225, 350, 3)
      @player = nil
    else
      @player.draw
    end
  end

  def update
    return unless @playing
    @player.turn_left if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp
    @player.move
    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @enemies.each(&:move)
    @bullets.each(&:move)
    @enemy_bullets.each(&:move)
    @enemies.dup.each do |enemy|
      @enemy_bullets.push Bullet.new(self, enemy.x, enemy.y, 180) if rand < ENEMY_FREQUENCY / 4
      @bullets.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
        end
        @bullets.delete bullet unless bullet.onscreen?
        @enemy_bullets.delete bullet unless bullet.onscreen?
      end
      @enemy_bullets.each do |bullet|
        distance = Gosu.distance(@player.x, @player.y, bullet.x, bullet.y)
        if distance < @player.radius + bullet.radius
          @playing = false
          @enemy_bullets.delete bullet
          @explosions.push Explosion.new(self, @player.x, @player.y)
        end
        @bullets.delete bullet unless bullet.onscreen?
        @enemy_bullets.delete bullet unless bullet.onscreen?
      end
      @enemies.delete enemy if enemy.y > HEIGHT + enemy.radius
      @explosions.dup.each do |explosion|
        distance = Gosu.distance(enemy.x, enemy.y, explosion.x, explosion.y)
        if distance < enemy.radius + explosion.radius
          @enemies.delete enemy
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
        end
        @explosions.delete explosion if explosion.finished
      end
    end
  end

  def button_down(id)
    unless @playing
      if (id == Gosu::KbReturn)
        @playing = true
        @player = Player.new(self)
        @enemies = []
        @bullets = []
        @enemy_bullets = []
        @explosions = []
      else
        return
      end
    end
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end
  end
end
window = SectorFive.new
window.show
