require 'gosu'
require 'json'

class TypingGame < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = "Typing Game"

        @font = Gosu::Font.new(32)
        @big_font = Gosu::Font.new(48)
        @input = ""
        @score = 0
        @state = :title
        @selected_mode = nil
        @mode_index = 0
        @selected_level = nil
        @level_index = 0
        @words_data = load_words("question.json")

        @words = ["hello", "world", "ruby", "gosu", "typing", "game"]
        @current_word = ""
        @type_sound = Gosu::Sample.new("type.wav")
        @miss_sound = Gosu::Sample.new("miss.wav")
        @back_sound = Gosu::Song.new("back.wav")

        @time_limit = 30
        @remaining_time = @time_limit
        @last_tick = 0
    end

    def load_words(path)
        JSON.parse(File.read(path))
    end

    def update
        case @state
            when :title
                return
            when :game
                now = Gosu.milliseconds
                if now - @last_tick >= 1000
                    @remaining_time -= 1
                    @last_tick = now
                end

                if @remaining_time <= 0
                    @state = :result
                end

                if @input == @current_word
                    @score += 1
                    @input = ""
                    @current_word = @words.sample
                end
        end
    end

    def draw
        case @state
            when :title
                draw_title_screen
            when :mode_select
                draw_mode_select_screen
            when :level_select
                draw_level_select_screen
            when :game
                draw_game_screen
            when :result
                draw_result_screen
        end
    end

    def draw_title_screen
        @big_font.draw_text("Typing Game", 220, 200, 0, 1.5, 1.5, Gosu::Color::BLUE)
        @font.draw_text("Press Enter to Start", 250, 300, 0, 1.0, 1.0, Gosu::Color::WHITE)
    end

    def draw_mode_select_screen
        @big_font.draw_text("Select Mode", 280, 150, 0, 1.2, 1.2, Gosu::Color::AQUA)
        @words_data.keys.each_with_index do |mode, i|
            color = (i == @mode_index ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
            @font.draw_text("#{i + 1}. #{mode}", 300, 220 + i * 50, 0, 1.2, 1.2, color)
        end
    end

    def draw_level_select_screen
        levels = ["easy", "normal", "hard"]
        levels.each_with_index do |level, i|
            color = (i == @level_index ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
            @font.draw_text("#{i + 1}. #{level.capitalize}", 300, 240 + i * 50, 0, 1.2, 1.2, color)
        end
        @font.draw_text("Press ← Key to return SELECT MODE", 20, 560, 0, 1.0, 1.0, Gosu::Color::GRAY)
    end

    def draw_game_screen
        @font.draw_text("Time: #{@remaining_time}", 650, 30, 0, 1.0, 1.0, Gosu::Color::RED)

        @font.draw_text("Type this word:", 50, 100, 0)
        @font.draw_text(@current_word, 50, 150, 0, 1.5, 1.5, Gosu::Color::YELLOW)

        @font.draw_text("Your input:", 50, 250, 0)
        @font.draw_text(@input, 50, 300, 0, 1.2, 1.2, Gosu::Color::WHITE)
        
        @font.draw_text("Score: #{@score}", 50, 500, 0)
    end

    def draw_result_screen
        @big_font.draw_text("Time's up!", 280, 180, 0, 1.3, 1.3, Gosu::Color::FUCHSIA)
        @font.draw_text("Your score: #{@score}", 320, 270, 0)
        @font.draw_text("Press Enter to return to Title", 240, 350, 0)
    end
    
    def button_down(id)
        case @state
            when :title
                if id == Gosu::KB_RETURN
                    @state = :mode_select
                elsif id == Gosu::KB_ESCAPE
                    close
                end

            when :mode_select
                modes = @words_data.keys
                
                case id
                when Gosu::KB_DOWN
                    @mode_index = (@mode_index + 1) % modes.size
                when Gosu::KB_UP
                    @mode_index = (@mode_index - 1) % modes.size
                when Gosu::KB_RETURN
                    @selected_mode = modes[@mode_index]
                    @state = :level_select
                when Gosu::KB_1 .. Gosu::KB_9
                    index = id - Gosu::KB_1
                    if index < modes.size
                        @selected_mode = modes[index]
                        @state = :level_select
                    end
                end
        
            when :level_select
                levels = ["easy", "normal", "hard"]

                case id
                when Gosu::KB_DOWN
                    @level_index = (@level_index + 1) % levels.size
                when Gosu::KB_UP
                    @level_index = (@level_index - 1) % levels.size
                when Gosu::KB_RETURN
                    start_game(levels[@level_index])
                when Gosu::KB_LEFT
                    @state = :mode_select
                when Gosu::KB_1 .. Gosu::KB_3
                    index = id - Gosu::KB_1
                    start_game(levels[index]) if index < levels.size
                end

            when :game
                case id
                    when Gosu::KB_ESCAPE
                        close
                    when Gosu::KB_BACKSPACE
                        @input.chop!
                        @back_sound.play
                    when Gosu::KB_RETURN
                    if @input != @current_word
                        @miss_sound.play
                        @input = ""
                    end
                else
                    if id.between?(Gosu::KB_A, Gosu::KB_Z)
                        @input << (65 + (id - Gosu::KB_A)).chr.downcase
                        @type_sound.play
                    end
                end

            when :result
            if id == Gosu::KB_RETURN
                @state = :title
            end
        end
    end

    def start_game(level)
        @selected_level = level 
        @words = @words_data[@selected_mode][@selected_level]

        @state = :game
        @score = 0
        @input = ""
        @current_word = @words.sample
        @remaining_time = @time_limit
        @last_tick = Gosu.milliseconds
    end
end

TypingGame.new.show