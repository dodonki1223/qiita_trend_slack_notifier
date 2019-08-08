# frozen_string_literal: true

require 'qiita_trend'
require './qiita_notifier/configuration'

QiitaNotifier.configure do |config|
  # Qiitaでログイン出来るユーザー名とパスワードをセットしてください
  config.user_name = 'user_name'
  config.password = 'password'
  # Slackで作成したアプリのWebHookURLを設定してください
  config.web_hook_url = 'web_hook_url'
end

QiitaTrend.configure do |config|
  config.user_name = QiitaNotifier.configuration.user_name
  config.password = QiitaNotifier.configuration.password
end
