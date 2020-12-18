# frozen_string_literal: true

require './qiita_notifier/slack_blocks'
require './qiita_notifier/slack_client'

module QiitaNotifier
  class QiitaNotifier
    attr_reader :web_hook_url, :trend_data, :trend_name, :blocks, :new_blocks, :channel

    # デフォルトユーザー画像URL
    DEFAULT_USER_IMAGE = 'https://qiita-image-store.s3.amazonaws.com/0/45617/015bd058-7ea0-e6a5-b9cb-36a4fb38e59c.png'

    # コンストラクタ
    def initialize(web_hook_url, trend_data, trend_name)
      @web_hook_url = web_hook_url
      @trend_data = trend_data
      @trend_name = trend_name
      @blocks = create_blocks(trend_data.items)
      @new_blocks = create_blocks(trend_data.new_items)
    end

    # トレンドをSlackに通知する
    def item_notify
      notify(@blocks)
    end

    # NewのもののトレンドをSlackに通知する
    def new_item_notify
      notify(@new_blocks)
    end

    private

    # blocksを作成する
    def create_blocks(trend_data)
      blocks = trend_data.each_with_object([]) do |item, result|
        title = SlackBlocks.build_bold_text(SlackBlocks.build_link_text(item['article'], item['title']))
        user_link = SlackBlocks.build_link_text(item['user_page'], item['user_name'])
        post_date = convert_qiita_post_date(item['published_at'])
        content = SlackBlocks.build_qiita_content(item['is_new_arrival'], user_link, post_date, item['likes_count'])

        text = SlackBlocks.build_qiita(title, content)
        image = SlackClient.new(item['user_image'], true).exists_url? ? item['user_image'] : DEFAULT_USER_IMAGE

        result.push SlackBlocks.section_with_image(text, image)
        result.push SlackBlocks.divider
      end

      notify_title = SlackBlocks.build_bold_text(notify_article_time)
      blocks.insert(0, SlackBlocks.section(notify_title))
      blocks.insert(1, SlackBlocks.divider)
      blocks
    end

    # Slackに通知する
    def notify(blocks)
      blocks.each_slice(21) do |block|
        post_data = SlackBlocks.build_post_data("Qiita：#{notify_article_time}", block)
        slack_client = SlackClient.new(@web_hook_url, true)
        request = slack_client.create_post_request(post_data)
        response = slack_client.start { |http| http.request(request) }

        puts "#{response.code}：#{response.message}"
      end
    end

    # 通知するQiitaの時間を取得する
    def notify_article_time
      if Time.now.hour >= 5 && Time.now.hour < 17
        "#{Date.today.strftime('%Y年%m月%d日')}05時の#{@trend_name}のトレンド"
      elsif Time.now.hour >= 17
        "#{Date.today.strftime('%Y年%m月%d日')}17時の#{@trend_name}のトレンド"
      elsif Time.now.hour < 5
        "#{(Date.today - 1).strftime('%Y年%m月%d日')}17時の#{@trend_name}のトレンド"
      end
    end

    # 現在時間から記事の投稿時間をqiitaの表記に変換する
    def convert_qiita_post_date(date_time)
      diff = DateTime.now - DateTime.parse(date_time)

      # 求めた差分を秒に変換する(diffはRationalクラス)
      diff_second = (diff * 24 * 60 * 60).to_i

      # 秒を時間に変換する
      diff_hour = diff_second / (60 * 60)
      return "#{diff_hour} hours ago" if diff_hour <= 23

      # 時間を日付に変換する
      diff_day = diff_hour / 24
      "#{diff_day} days ago"
    end
  end
end
