require 'gosu'
require_relative 'player'
require_relative 'enemy'

class SectorFive < Gosu::Window
  ENEMY_FREQUENCY = 0.01
  def initialize
    super(800, 600)
    self.caption = 'Sector Five'
    @player = Player.new(self)
    @enemies = []
  end

  def draw
    @player.draw
    @enemies.each do |enemy|
      enemy.draw
    end
  end

  def update
    @player.turn_left if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp
    @player.move
    if rand < ENEMY_FREQUENCY
      @enemies.push Enemy.new(self)
    end
    @enemies.each do |enemy|
      enemy.move
    end
  end
end
window = SectorFive.new
window.show
