class BotBase
  def initialize(update)
    STDERR.puts update

    @message = update.inline_query if update.inline_query
    @message = update.edited_message if update.edited_message
    @message ||= update.message
    raise "No message in #{update.to_h}" unless @message
  end

  def perform
    if command && respond_to?(command_method)
      send command_method
    else
      if session_storage.get_state
        STDERR.puts 'get_state'
        if respond_to? state_method
          STDERR.puts 'responde'
          send state_method
        else
          command_offer
        end
      else
        reply "Нет такой комманды (/#{command}). Попробуй /start"
      end
    end
  end

  def command_state
    reply session_storage.get_state || 'no state'
  end

  private

  attr_reader :message

  def state_method
    state = session_storage.get_state
    "state_#{state}"
  end

  def reply(text)
    log "reply: #{text}"
    client.send_message(chat_id: message.chat.id, text: text || 'no_message')
  end

  def in_reply(text)
    log "in_reply: #{text}"
    client.send_message(
      chat_id: message.chat.id,
      text: text
      # reply_to_message_id: message.message_id.to_s
      # reply_markup: Telegrammer::DataTypes::ForceReply.new(force_reply: true)
    )
  end

  def log(msg)
    STDERR.puts "LOG [chat_id:#{message.chat.id}]: #{msg}"
  end

  def command
    return nil unless message.text
    first = message.text.split(' ')[0]
    if first[0]=='/'
      first.tr('/','')
    else
      nil
    end
  end

  def command_method
    "command_#{command}"
  end

  def session_storage
    @session_storage ||= SessionStorage.new(chat_id: message.chat.id, from_id: message.from.id)
  end

  def client
    Telegrammer::Bot.new token
  end

  def token
    ENV['TELEGRAM_TOKEN']
  end

  def generate_file_url(file_path)
    "https://api.telegram.org/file/bot#{token}/#{file_path}"
  end

  def get_photo(message)
    photo = message.photo[0]
    return photo if photo
    document = message.document
    return document if document && document.mime_type=~/image/

    nil
  end

  def get_photo_url(photo)
    if photo.respond_to?(:file_path) && photo.file_path
      generate_file_url photo.file_path
    else
      client.get_file(file_id: photo['file_id'])
    end
  end
end
