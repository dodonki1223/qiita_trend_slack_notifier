# frozen_string_literal: true

require 'qiita_trend'
require './qiita_notifier/qiita_notifier'
require './config'

weekly_trend = QiitaTrend::Trend.new(QiitaTrend::TrendType::WEEKLY)
qiita_notifier = QiitaNotifier::QiitaNotifier.new(QiitaNotifier.configuration.web_hook_url, weekly_trend)
qiita_notifier.new_item_notify
