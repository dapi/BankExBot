require 'monetize'
require_relative 'bot_base'

class AppBot < BotBase
  def command_start
    reply "Введите /offer для публикации предложения. #{AppVersion}"
  end

  def command_test
  end

  def command_Опубликовать
    reply 'Опубликовал'
    session_storage.clear_state
  end

  def command_offer
    in_reply 'Введите заголовок объявления'
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_TITLE
  end

  def command_ping
    reply 'pong'
  end

  def command_debug
    data = {
      offer: offer,
      state: session_storage.get_state,
      next_state: session_storage.next_state,
      from: message.from.to_h,
      version: AppVersion
    }
    reply data.to_s
  end

  def state_new_offer_title
    in_reply "Установлен заголовок: '#{message.text}'. Введите описание."

    session_storage.set_next_state
    session_storage.set_offer_attribute :title, message.text
  end

  def state_new_offer_desc
    in_reply "Установлено описание: '#{message.text}'. Введите цену."
    session_storage.set_next_state
    session_storage.set_offer_attribute :description, message.text
  end

  def state_new_offer_price
    money = Monetize.parse message.text
    in_reply "Установлена цена: '#{money}'. Введите теги через запятую"
    session_storage.set_next_state
    session_storage.set_offer_attribute :price, money.to_f
  end

  def state_new_offer_tags
    tags = message.text.split(',')
    session_storage.set_next_state
    session_storage.set_offer_attribute :tags, tags.join(',')
    publicate?
  end

  def state_new_offer_publicate
    publicate?
  end

  def publicate?
    rm = Telegrammer::DataTypes::ReplyKeyboardMarkup.new(
      keyboard: [['/Опубликовать']],
      one_time_keyboard: true
    )

    text = "У нас получилось следующее объявление.\n---\n#{offer_text}\n---\nПубликуем?"
    client.send_message chat_id: message.chat.id, text: text, reply_markup: rm
  end

  def offer_text
    [
      "Заголовок: #{offer['title']}",
      "Описание: #{offer['descriiption']}",
      "Цена: #{offer['price']}",
      "Теги: #{offer['tags']}"
    ].join("\n")
  end

  def offer
    session_storage.get_offer
  end
end
