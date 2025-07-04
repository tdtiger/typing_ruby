require 'gosu'

class TypingGame < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = "Typing Game"

        @font = Gosu::Font.new(32)
        @big_font = Gosu::Font.new(48)
        @input = ""
        @score = 0
        @state = :title

        @words = ["hello", "world", "ruby", "gosu", "typing", "game"]
        @current_word = ""
        @type_sound = Gosu::Sample.new("type.wav")
        @miss_sound = Gosu::Sample.new("miss.wav")
        @back_sound = Gosu::Song.new("back.wav")
    end

    def update
        return if @state == :title

        if @input == @current_word
            @score += 1
            @input = ""
            @current_word = @words.sample
        end
    end

    def draw
        case @state
        when :title
            draw_title_screen
        when :game
            draw_game_screen
        end
    end

    def draw_title_screen
        @big_font.draw_text("Typing Game", 220, 200, 0, 1.5, 1.5, Gosu::Color::BLUE)
        @font.draw_text("Press Enter to Start", 250, 300, 0, 1.0, 1.0, Gosu::Color::WHITE)
    end

    def draw_game_screen
        @font.draw_text("Type this word:", 50, 100, 0)
        @font.draw_text(@current_word, 50, 150, 0, 1.5, 1.5, Gosu::Color::YELLOW)

        @font.draw_text("Your input:", 50, 250, 0)
        @font.draw_text(@input, 50, 300, 0, 1.2, 1.2, Gosu::Color::WHITE)
        
        @font.draw_text("Score: #{@score}", 50, 500, 0)
    end
    
    def button_down(id)
        case @state
        when :title
            if id == Gosu::KB_RETURN
                start_game
            elsif id == Gosu::KB_ESCAPE
                close
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
        end
    end

    def start_game
        @state = :game
        @score = 0
        @input = ""
        @current_word = @words.sample
    end
end

TypingGame.new.show