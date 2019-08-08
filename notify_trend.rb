# frozen_string_literal: true

require 'qiita_trend'
require './qiita_notifier/qiita_notifier'
require './qiita_notifier/command_line_arg'
require './config'

# コマンドライン引数を取得
command_line_args = CommandLineArg.new
trend_type = command_line_args.get(:target)
is_new = command_line_args.get(:new)

# Qiita通知クラスを作成
daily_trend = QiitaTrend::Trend.new(trend_type)
qiita_notifier = QiitaNotifier::QiitaNotifier.new(QiitaNotifier.configuration.web_hook_url, daily_trend, trend_type)

# Slack通知の実行
if is_new
  qiita_notifier.new_item_notify
else
  qiita_notifier.item_notify
end
