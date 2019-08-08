# frozen_string_literal: true

require 'optparse'

# コマンドライン引数クラス
#   コマンドから受け取ったコマンドライン引数をパースして
#   プログラムから扱えるようにする機能を提供する
class CommandLineArg
  attr_accessor :options

  # コンストラクタ
  #   コマンドライン引数を受け取れるキーワードの設定、ヘルプコマンドが実行
  #   された時のメッセージの設定
  #   コマンドライン引数の値を取得するようのHash変数の作成
  def initialize
    # コマンドライン引数の値をセットするHash変数
    @options = {}
    OptionParser.new do |opt|
      # ヘルプコマンドを設定
      opt.on('-h', '--help', 'Show this help') do
        puts opt
        exit
      end

      # 値を受け取る系のコマンドライン引数を設定する
      @options[:target] = QiitaTrend::TrendType::DAILY
      opt.on('-t', '--target [TREND_TARGET]', 'Set trend target(daily, weekly, monthly) default daily') do |v|
        unless [QiitaTrend::TrendType::DAILY, QiitaTrend::TrendType::WEEKLY, QiitaTrend::TrendType::MONTHLY].include?(v)
          puts 'トレンドタイプが正しくありません(daily, weekly, monthly)'
          exit
        end
        set_command_line_arg_value(v, :target, 'トレンドタイプ（daily, weekly, monthly）')
      end

      # true、falseを受け取るコマンドライン引数を設定する
      @options[:new] = false
      opt.on('--new [NEW]', 'Get only new trend') { @options[:new] = true }

      # コマンドラインをparseする
      opt.parse!(ARGV)
    end
  end

  # 対象のコマンドライン引数が存在するか？
  def has?(name)
    @options.include?(name)
  end

  # 対象のコマンドライン引数の値を取得する
  #   対象のコマンドライン引数の値が存在しない場合は空文字を返す
  def get(name)
    return '' unless has?(name)

    @options[name]
  end

  private

  # コマンドライン引数をインスタンス変数にセットする
  #   もし対象のコマンドライン引数がnilの時はメッセージを表示して処理を終了する
  def set_command_line_arg_value(value, key, param_name)
    if value.nil?
      puts "#{param_name}のパラメータを指定して下さい"
      exit
    end
    @options[key] = value
  end
end
