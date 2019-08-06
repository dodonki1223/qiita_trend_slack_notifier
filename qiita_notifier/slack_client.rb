# frozen_string_literal: true

require 'net/https'

module QiitaNotifier
  # Slack通知の機能を提供するクラス
  # PostやGet方法については公式ドキュメントを参照すること
  # https://docs.ruby-lang.org/ja/latest/library/net=2fhttp.html
  class SlackClient
    attr_reader :client, :url

    # コンストラクタ
    def initialize(uri, use_ssl = false)
      @url = URI.parse(uri)
      @client = create_http_client(@url, use_ssl)
    end

    # Request実行用のメソッド
    def start
      yield(@client)
    end

    # 対象のURLが存在するかどうか
    def exists_url?
      response = @client.start { |http| http.get(@url.path) }.code
      response == '200'
    end

    # Request用のインスタンスを生成する
    def create_post_request(post_data)
      request = Net::HTTP::Post.new(@url.path)
      request.initialize_http_header('Content-Type' => 'application/json')
      request.set_form_data(post_data)
      request
    end

    private

    # Net::HTTPのクラスのインスタンスを生成する
    def create_http_client(url, use_ssl)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = use_ssl
      http
    end
  end
end
