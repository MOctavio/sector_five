require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'

class SectorFiveScenes < Gosu::Window
  ENEMY_FREQUENCY = 0.02
  MAX_ENEMIES = 100
  WIDTH = 800
  HEIGHT = 600

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Sector Five'
    @background_image = Gosu::Image.new('images/start_screen.png')
    @scene = :start
    @score_font = Gosu::Font.new(21)
  end

  def initialize_game
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @enemy_bullets = []
    @explosions = []
    @scene = :game
    @enemies_count = 0
    @enemies_destroyed = 0
  end

  def initialize_end(status)
    case status
    when :count_reached
      @message = "You made it! You destroyed #{@enemies_destroyed} ships"
      @message_two = "and only #{MAX_ENEMIES - @enemies_destroyed} reached the base"
      @message_two += 'where they were destroyed!'
    when :hit_by_enemy
      @message = "Hi there! I'm sorry but you were hit by an enemy ship."
      @message_two = 'However before your ship was destroyed you took out '
      @message_two += "#{@enemies_destroyed} enemy ships."
    when :off_top
      @message = 'Hi there! Why did you run from combat ?'
      @message_two = "You took out #{@enemies_destroyed} enemy ships but we still counted on you!"
    end

    @game_message = 'Press P to play again or Q to quit.'

    @message_font = Gosu::Font.new(21)
    @credits = []
    y = 500
    File.open('credits.txt').each do |line|
      @credits.push(Credit.new(self, line.chomp, 100, y))
      y += 30
    end
    @scene = :end
  end

  def draw
    case @scene
    when :start
      draw_start
    when :game
      draw_game
    when :end
      draw_end
    end
  end

  def draw_start
    @background_image.draw(0, 0, 0)
  end

  def draw_game
    @enemies.each(&:draw)
    @bullets.each(&:draw)
    @enemy_bullets.each(&:draw)
    @explosions.each(&:draw)
    @player.draw
    @score = "SCORE #{@enemies_destroyed}"
    @score_font.draw(@score, 40, 40, 1, 1, 1, Gosu::Color::GRAY)
  end

  def draw_end
    clip_to(40, 180, 700, 360) do
      @credits.each(&:draw)
    end
    @message_font.draw(@message, 40, 40, 1, 1, 1, Gosu::Color::GRAY)
    @message_font.draw(@message_two, 40, 75, 1, 1, 1, Gosu::Color::GRAY)
    @message_font.draw(@game_message, 40, 125, 1, 1, 1, Gosu::Color::AQUA)
    draw_line(0, 180, Gosu::Color::GRAY, WIDTH, 180, Gosu::Color::GRAY)
  end

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end

  def update_game
    @player.turn_left if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp
    @player.move
    if rand < ENEMY_FREQUENCY
      @enemies.push Enemy.new(self)
      @enemies_count += 1
      initialize_end(:count_reached) if @enemies_count > MAX_ENEMIES
    end
    @enemies.each(&:move)
    @bullets.each(&:move)
    @enemy_bullets.each(&:move)
    @enemies.dup.each do |enemy|
      @enemy_bullets.push Bullet.new(self, enemy.x, enemy.y, 180) if rand < ENEMY_FREQUENCY / 4
      # fire to enemies
      @bullets.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies_destroyed += 1
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
        end
        @bullets.delete bullet unless bullet.onscreen?
        @enemy_bullets.delete bullet unless bullet.onscreen?
      end
      # enemy fire
      @enemy_bullets.each do |bullet|
        distance = Gosu.distance(@player.x, @player.y, bullet.x, bullet.y)
        if distance < @player.radius + bullet.radius
          @enemy_bullets.delete bullet
          @explosions.push Explosion.new(self, @player.x, @player.y)
          initialize_end(:hit_by_enemy)
        end
        @bullets.delete bullet unless bullet.onscreen?
        @enemy_bullets.delete bullet unless bullet.onscreen?
      end
      # enemy out of screen
      @enemies.delete enemy if enemy.y > HEIGHT + enemy.radius
      # general explosions
      player_distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
      @explosions.dup.each do |explosion|
        enemy_distance = Gosu.distance(enemy.x, enemy.y, explosion.x, explosion.y)
        if enemy_distance < enemy.radius + explosion.radius
          @enemies.delete enemy
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @enemies_count += 1
        end
        if player_distance < @player.radius + enemy.radius
          @explosions.push Explosion.new(self, @player.x, @player.y)
        end
        @explosions.delete explosion if explosion.finished
      end
      initialize_end(:hit_by_enemy) if player_distance < @player.radius + enemy.radius
      initialize_end(:off_top) if @player.y < -@player.radius
    end
  end

  def update_end
    @credits.each(&:move)
    @credits.each(&:reset) if @credits.last.y < 150
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  def button_down_start(_id)
    initialize_game
  end

  def button_down_game(_id)
    if _id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end
  end

  def button_down_end(_id)
    if _id == Gosu::KbP
      initialize_game
    elsif _id == Gosu::KbQ
      close
    end
  end
end
window = SectorFiveScenes.new
window.show
