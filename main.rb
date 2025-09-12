require 'gosu'
require 'json'

class TypingGame < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = "LaTeX Typing Game"

        @font = Gosu::Font.new(32)
        @big_font = Gosu::Font.new(48)

        @input = ""

        # 得点管理
        @score = 0
        @combo = 0
        @max_combo = 0

        # 状態管理
        @state = :title

        # 問題
        @questions_data = load_words("question.json")
        @current_question = nil
        @question_image = nil
        @used_questions = []

        # 効果音
        @type_sound = Gosu::Sample.new("sound/type.wav")
        @miss_sound = Gosu::Sample.new("sound/miss.wav")
        @back_sound = Gosu::Song.new("sound/back.wav")

        # 時間の管理
        @time_limit = 60
        @remaining_time = @time_limit
        @last_tick = 0
    end

    # 問題ファイルの読み込み
    def load_words(path)
        JSON.parse(File.read(path))
    end

    def update
        # 状態に応じて処理を分岐
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

                if @input == @current_question["word"]
                    @score += @combo / 5 + 1
                    @combo += 1
                    @max_combo = [@max_combo, @combo].max
                    @input = ""
                    @current_question = pick_next_question
                    @question_image = Gosu::Image.new(@current_question["image"])
                end
        end
    end

    def draw
        # 状態に適した描画関数を呼び出し
        case @state
            when :title
                draw_title_screen
            when :game
                draw_game_screen
            when :result
                draw_result_screen
        end
    end

    # タイトル画面の描画　
    def draw_title_screen
        @big_font.draw_text("LaTeX Typing Game", 150, 200, 0, 1.3, 1.3, Gosu::Color::BLUE)
        @font.draw_text("Press Enter to Start", 250, 320, 0, 1.0, 1.0, Gosu::Color::WHITE)
    end

    # プレイ画面の描画
    def draw_game_screen
        @font.draw_text("Time: #{@remaining_time}", 650, 30, 0, 1.0, 1.0, Gosu::Color::RED)

        @font.draw_text("Type this:", 50, 100, 0)
        @font.draw_text(@current_question["word"], 195, 90, 0, 1.5, 1.5, Gosu::Color::YELLOW)

        @font.draw_text("Description: #{@current_question["desc"]}", 50, 150, 0, 1.0, 1.0, Gosu::Color::GRAY)

        @question_image.draw(50, 200, 0, 0.3, 0.3)

        @font.draw_text("Your input:", 50, 350, 0)
        @font.draw_text(@input, 195, 349, 0, 1.2, 1.2, Gosu::Color::WHITE)
        
        @font.draw_text("Score: #{@score}", 50, 500, 0)
        @font.draw_text("Combo: #{@combo}", 50, 540, 0)
    end

    # リザルト画面の描画
    def draw_result_screen
        @big_font.draw_text("Time's up!", 280, 180, 0, 1.3, 1.3, Gosu::Color::FUCHSIA)
        @font.draw_text("Your score: #{@score}", 320, 270, 0)
        @font.draw_text("Max Combo: #{@max_combo}", 320, 310, 0)
        @font.draw_text("Press Enter to return to Title", 240, 350, 0)
    end
    
    # キー入力の処理
    def button_down(id)
        case @state
            when :title
                # ゲーム開始もしくは終了
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
                        @combo = 0
                        @input = ""
                    end
                else
                    char = button_id_to_char(id)
                    if char
                        @input << char
                        @type_sound.play
                    end
                end

            when :result
            if id == Gosu::KB_RETURN
                @state = :title
            end
        end
    end

    # キーコードを文字に変換
    def button_id_to_char(id)
        if id.between?(Gosu::KB_A, Gosu::KB_Z)
            return (65 + (id - Gosu::KB_A)).chr.downcase
        elsif id == Gosu::KB_BACKTICK 
            return "`"
        elsif id == Gosu::KB_MINUS
            return "-"
        elsif id == Gosu::KB_EQUALS
            return "="
        elsif id == Gosu::KB_LEFT_BRACKET
            return "["
        elsif id == Gosu::KB_RIGHT_BRACKET
            return "]"
        elsif id == Gosu::KB_BACKSLASH
            return "\\"
        elsif id == Gosu::KB_SEMICOLON
            return ";"
        elsif id == Gosu::KB_APOSTROPHE
            return "'"
        elsif id == Gosu::KB_COMMA
            return ","
        elsif id == Gosu::KB_PERIOD
            return "."
        elsif id == Gosu::KB_SLASH
            return "/"  
        elsif id == Gosu::KB_SPACE
            return " "
        elsif id == Gosu::KB_0 .. Gosu::KB_9
            return (id - Gosu::KB_0).to_s
        elsif id == Gosu::KB_ESCAPE
            return "_"
        else
            return nil
        end
    end

    # ゲーム開始時の初期化を行う
    def start_game
        @state = :game
        @score = 0
        @combo = 0
        @max_combo = 0
        @input = ""
        @current_question = pick_next_question
        @question_image = Gosu::Image.new(@current_question["image"])
        @remaining_time = @time_limit
        @last_tick = Gosu.milliseconds
    end

    def pick_next_question
        available = @questions_data - @used_questions
        if available.empty?
            @used_questions.clear
            available = @questions_data.dup
        end
        q = available.sample
        @used_questions << q
        q
    end
end

TypingGame.new.show