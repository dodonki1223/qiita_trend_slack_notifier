# frozen_string_literal: true

require 'qiita_trend'
require './qiita_notifier/qiita_notifier'
require './config'

monthly_trend = QiitaTrend::Trend.new(QiitaTrend::TrendType::MONTHLY)
qiita_notifier = QiitaNotifier::QiitaNotifier.new(QiitaNotifier.configuration.web_hook_url, monthly_trend)
qiita_notifier.item_notify
