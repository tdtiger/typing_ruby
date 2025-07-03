require 'gosu'

class TypingGame < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = "Typing Game"
        @font = Gosu::Font.new(32)
        @input = ""
        @score = 0

        @words = ["hello", "world", "ruby", "gosu", "typing", "game"]
        @current_word = @words.sample
    end

    def update
        if @input == @current_word
            @score += 1
            @input = ""
            @current_word = @words.sample
        end
    end

    def draw
        @font.draw_text("Type this word:", 50, 100, 0)
        @font.draw_text(@current_word, 50, 150, 0, 1.5, 1.5, Gosu::Color::YELLOW)

        @font.draw_text("Your input:", 50, 250, 0)
        @font.draw_text(@input, 50, 300, 0, 1.2, 1.2, Gosu::Color::WHITE)
        
        @font.draw_text("Score: #{@score}", 50, 500, 0)
    end
    
    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        elsif id.between?(Gosu::KB_A, Gosu::KB_Z)
            @input << (65 + (id - Gosu::KB_A)).chr.downcase
        elsif id == Gosu::KB_BACKSPACE
            @input.chop!
        elsif id == Gosu::KB_RETURN
        end
    end
end

TypingGame.new.show