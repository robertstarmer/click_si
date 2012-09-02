require 'em-hiredis'

redis = EM::Hiredis.connect
subscriber = EM::Hiredis.connect

subscriber.subscribe('bar.0')
subscriber.psubscribe('bar.*')

subscriber.on(:message) { |channel, message|
  p [:message, channel, message]
}

subscriber.on(:pmessage) { |key, channel, message|
  p [:pmessage, key, channel, message]
}

EM.add_periodic_timer(1) {
  redis.publish("bar.#{rand(2)}", "hello").errback { |e|
    p [:publisherror, e]
  }
}
