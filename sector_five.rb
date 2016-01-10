require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'

class SectorFive < Gosu::Window
  ENEMY_FREQUENCY = 0.01
  def initialize
    super(800, 600)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
  end

  def draw
    @player.draw
    @enemies.each(&:draw)
    @bullets.each(&:draw)
  end

  def update
    @player.turn_left if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp
    @player.move
    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @enemies.each(&:move)
    @bullets.each(&:move)
    @enemies.dup.each do |enemy|
      @bullets.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
        end
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end
  end
end
window = SectorFive.new
window.show
