# frozen_string_literal: true

require 'qiita_trend'
require './qiita_notifier/qiita_notifier'
require './config'

daily_trend = QiitaTrend::Trend.new(QiitaTrend::TrendType::DAILY)
qiita_notifier = QiitaNotifier::QiitaNotifier.new(QiitaNotifier.configuration.web_hook_url, daily_trend)
qiita_notifier.item_notify
