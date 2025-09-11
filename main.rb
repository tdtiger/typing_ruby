require 'gosu'
require 'json'

class TypingGame < Gosu::Window
    def initialize
        super(800, 600)
        self.caption = "Typing Game"

        @font = Gosu::Font.new(32)
        @big_font = Gosu::Font.new(48)
        @input = ""

        # 得点管理
        @score = 0
        @combo = 0
        @max_combo = 0

        # 状態管理
        @state = :title

        # 言語とモード選択
        @selected_language = nil
        @language_index = 0
        @selected_mode = nil
        @mode_index = 0

        # 問題
        @words_data = load_words("question.json")
        @current_word = ""

        # 効果音
        @type_sound = Gosu::Sample.new("sound/type.wav")
        @miss_sound = Gosu::Sample.new("sound/miss.wav")
        @back_sound = Gosu::Song.new("sound/back.wav")

        # 時間の管理
        @time_limit = 30
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

                if @input == @current_word
                    @score += 1
                    @combo += 1
                    @max_combo = [@max_combo, @combo].max
                    @input = ""
                    @current_word = pick_next_word
                end
        end
    end

    def draw
        # 状態に適した描画関数を呼び出し
        case @state
            when :title
                draw_title_screen
            when :language_select
                draw_language_select_screen
            when :mode_select
                draw_mode_select_screen
            when :game
                draw_game_screen
            when :result
                draw_result_screen
        end
    end

    # タイトル画面の描画　
    def draw_title_screen
        @big_font.draw_text("Typing Game", 220, 200, 0, 1.5, 1.5, Gosu::Color::BLUE)
        @font.draw_text("Press Enter to Start", 250, 300, 0, 1.0, 1.0, Gosu::Color::WHITE)
    end

    # 言語選択画面の描画
    def draw_language_select_screen
        @big_font.draw_text("Select Language", 210, 150, 0, 1.2, 1.2, Gosu::Color::AQUA)
        @words_data.keys.each_with_index do |language, i|
            # 選択中の言語のみハイライト
            color = (i == @language_index ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
            @font.draw_text("#{i + 1}. #{language}", 300, 220 + i * 50, 0, 1.2, 1.2, color)
        end
    end

    # モード選択画面の描画
    def draw_mode_select_screen
        modes = @words_data[@selected_language].keys
        @big_font.draw_text("Select Mode (#{@selected_language})", 160, 150, 0, 1.2, 1.2, Gosu::Color::AQUA)
        modes.each_with_index do |mode, i|
            # 選択中のモードのみハイライト
            color = (i == @mode_index ? Gosu::Color::YELLOW : Gosu::Color::WHITE)
            @font.draw_text("#{i + 1}. #{mode}", 300, 220 + i * 50, 0, 1.2, 1.2, color)
        end
        @font.draw_text("Press ← Key to return SELECT LANGUAGE", 20, 560, 0, 1.0, 1.0, Gosu::Color::GRAY)
    end

    # プレイ画面の描画
    def draw_game_screen
        @font.draw_text("Time: #{@remaining_time}", 650, 30, 0, 1.0, 1.0, Gosu::Color::RED)

        @font.draw_text("Type this word:", 50, 100, 0)
        @font.draw_text(@current_word, 50, 150, 0, 1.5, 1.5, Gosu::Color::YELLOW)

        @font.draw_text("Your input:", 50, 250, 0)
        @font.draw_text(@input, 50, 300, 0, 1.2, 1.2, Gosu::Color::WHITE)
        
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
                # 言語選択画面へ移行もしくは終了
                if id == Gosu::KB_RETURN
                    @state = :language_select
                elsif id == Gosu::KB_ESCAPE
                    close
                end

            when :language_select
                languages = @words_data.keys
                
                case id
                when Gosu::KB_DOWN
                    @language_index = (@language_index + 1) % languages.size
                when Gosu::KB_UP
                    @language_index = (@language_index - 1) % languages.size
                when Gosu::KB_RETURN
                    @selected_language = languages[@language_index]
                    @state = :mode_select
                when Gosu::KB_1 .. Gosu::KB_9
                    index = id - Gosu::KB_1
                    if index < languages.size
                        @selected_language = languages[index]
                        @state = :mode_select
                    end
                end
        
            when :mode_select
                modes = @words_data[@selected_language].keys

                case id
                when Gosu::KB_DOWN
                    @mode_index = (@mode_index + 1) % modes.size
                when Gosu::KB_UP
                    @mode_index = (@mode_index - 1) % modes.size
                when Gosu::KB_RETURN
                    start_game(modes[@mode_index])
                when Gosu::KB_LEFT
                    @state = :language_select
                when Gosu::KB_1 .. Gosu::KB_3
                    index = id - Gosu::KB_1
                    start_game(modes[index]) if index < modes.size
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

    # ゲーム開始時の初期化を行う
    def start_game(mode)
        @selected_mode = mode 
        @words = @words_data[@selected_language][@selected_mode]
        @used_words = []

        @state = :game
        @score = 0
        @combo = 0
        @max_combo = 0
        @input = ""
        @current_word = @words.sample
        @remaining_time = @time_limit
        @last_tick = Gosu.milliseconds
    end

    def pick_next_word
        available = @words - @used_words
        if available.empty?
            @used_words.clear
            available = @words.dup
        end
        word = available.sample
        @used_words << word
        word
    end
end

TypingGame.new.show