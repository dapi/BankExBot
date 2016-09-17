require 'monetize'
require_relative 'bot_base'

class AppBot < BotBase
  def command_start
    reply "Введите /offer для публикации предложения. #{AppVersion}"
  end

  def command_offer
    reply 'Введите заголовок объявления'
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_TITLE
  end

  def command_ping
    reply 'pong'
  end

  def command_debug
    offer = session_storage.get_offer
    data = {
      offer: offer,
      state: session_storage.get_state,
      next_state: session_storage.next_state,
      from: message.from.to_h
    }
    reply data.to_s
  end

  def state_new_offer_title
    reply "Установлен заголовок: #{message.text}. Введите описание."
    session_storage.set_next_state
    session_storage.set_offer_attribute :title, message.text
  end

  def state_new_offer_desc
    reply "Установлено описание: #{message.text}. Введите цену."
    session_storage.set_next_state
    session_storage.set_offer_attribute :description, message.text
  end

  def state_new_offer_price
    money = Monetize.parse message.text
    reply "Установлена цена: #{money}. Введите теги через запятую"
    session_storage.set_next_state
    session_storage.set_offer_attribute :price, money.to_f
  end

  def state_new_offer_tags
    tags = message.text.split(',')
    reply "Теги: #{tags.join(',')}"
    session_storage.set_next_state
    session_storage.set_offer_attribute :tags, tags.join(',')
  end

  def state_new_offer_publicate
    reply "Публикуем?"
  end
end
