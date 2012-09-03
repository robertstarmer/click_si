require 'em-hiredis'

EM.run {
  subscriber = EM::Hiredis.connect

  subscriber.subscribe('button-1')
  subscriber.on(:message) { |channel, message|
    p [:message, channel, message]
  }

}
