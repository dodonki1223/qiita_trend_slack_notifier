# frozen_string_literal: true

require 'json'

module QiitaNotifier
  # blocks用のデータを作成する機能を提供するクラス
  # https://api.slack.com/reference/messaging/blocks
  class SlackBlocks
    # リンクテキストを作成する
    def self.build_link_text(link, text)
      "<#{link}|#{text}>"
    end

    # 太字のテキストを作成する
    def self.build_bold_text(text)
      "*#{text}*"
    end

    # blocksの`Section`を作成する
    # https://api.slack.com/tools/block-kit-builder?blocks=%5B%7B%22type%22%3A%22section%22%2C%22text%22%3A%7B%22type%22%3A%22mrkdwn%22%2C%22text%22%3A%22This%20is%20a%20mrkdwn%20section%20block%20%3Aghost%3A%20*this%20is%20bold*%2C%20and%20~this%20is%20crossed%20out~%2C%20and%20%3Chttps%3A%2F%2Fgoogle.com%7Cthis%20is%20a%20link%3E%22%7D%7D%5D
    def self.section(text)
      {
        'type' => 'section',
        'text' => {
          'type' => 'mrkdwn',
          'text' => text
        }
      }
    end

    # blocksの`Section with Image`を作成する
    # https://api.slack.com/tools/block-kit-builder?blocks=%5B%7B%22type%22%3A%22section%22%2C%22text%22%3A%7B%22type%22%3A%22mrkdwn%22%2C%22text%22%3A%22Take%20a%20look%20at%20this%20image.%22%7D%2C%22accessory%22%3A%7B%22type%22%3A%22image%22%2C%22image_url%22%3A%22https%3A%2F%2Fapi.slack.com%2Fimg%2Fblocks%2Fbkb_template_images%2Fpalmtree.png%22%2C%22alt_text%22%3A%22palm%20tree%22%7D%7D%5D
    def self.section_with_image(text, image)
      {
        'type' => 'section',
        'text' => {
          'type' => 'mrkdwn',
          'text' => text
        },
        'accessory' => {
          'type' => 'image',
          'image_url' => image,
          'alt_text' => 'user image'
        }
      }
    end

    # Slack通知用のQiita記事内容を作成する
    def self.build_qiita_content(is_new_arrival, user, post_date, likes_count)
      new_stamp = is_new_arrival ? ':new:' : ''
      "#{new_stamp} by #{user} #{post_date} :thumbsup: #{likes_count}"
    end

    # Slack通知用のQiitaの内容（タイトルと記事内容）を作成する
    def self.build_qiita(title, content)
      "#{title} \n\n #{content}"
    end

    # blocksの`Divider`を作成する
    # https://api.slack.com/tools/block-kit-builder?blocks=%5B%7B%22type%22%3A%22divider%22%7D%5D
    def self.divider
      {
        'type' => 'divider'
      }
    end

    # blocksのポストデータを作成する
    def self.build_post_data(text, blocks)
      {
        'payload' => {
          'text' => text,
          'blocks' => blocks
        }.tap do |payload|
          payload['channel'] = ::QiitaNotifier.configuration.channel unless ::QiitaNotifier.configuration.channel.nil?
        end.to_json
      }
    end
  end
end
