# frozen_string_literal: true

require './qiita_notifier/slack_blocks'
require './qiita_notifier/slack_client'

module QiitaNotifier
  class QiitaNotifier
    attr_reader :web_hook_url, :trend_data, :blocks, :new_blocks

    # デフォルトユーザー画像URL
    DEFAULT_USER_IMAGE = 'https://qiita-image-store.s3.amazonaws.com/0/45617/015bd058-7ea0-e6a5-b9cb-36a4fb38e59c.png'

    # コンストラクタ
    def initialize(web_hook_url, trend_data)
      @web_hook_url = web_hook_url
      @trend_data = trend_data
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
        text = SlackBlocks.build_qiita(
          SlackBlocks.build_qiita_title(item['title'], item['article']),
          SlackBlocks.build_qiita_content(item['is_new_arrival'], item['user_name'], item['likes_count'])
        )
        image = SlackClient.new(item['user_image'], true).exists_url? ? item['user_image'] : DEFAULT_USER_IMAGE

        result.push SlackBlocks.section_with_image(text, image)
        result.push SlackBlocks.divider
      end
      blocks
    end

    # Slackに通知する
    def notify(blocks)
      blocks.each_slice(15) do |block|
        post_data = SlackBlocks.build_post_data('Qiitaトレンド', block)
        slack_client = SlackClient.new(@web_hook_url, true)
        request = slack_client.create_post_request(post_data)
        response = slack_client.start { |http| http.request(request) }

        puts "#{response.code}：#{response.message}"
      end
    end
  end
end
