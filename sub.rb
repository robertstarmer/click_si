require 'em-hiredis'

EM.run {
  subscriber = EM::Hiredis.connect

  subscriber.psubscribe('button:*')
  subscriber.on(:pmessage) { |key, channel, message|
      p [:pmessage, key, channel, message]
  }

}
