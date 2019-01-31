class SlackClient
	def initialize
    @client = Slack::Web::Client.new
  end

	def get_slack_username(email)
	    begin
	    	user = @client.users_lookupByEmail('email': email)
	    	return user.user.name
	    rescue Exception => e
	    	puts e
	    	return nil
	    end
	end

  def reassign_slack_username(user)
    user.slack_username = get_slack_username(user.email)
    user.save
  end

  def try_send(user, message, attachments)
    tries ||= 2
    @client.chat_postMessage(channel: "@#{user.slack_username}", text: message, attachments: attachments)
  rescue Slack::Web::Api::Error => e
    return if e.message != 'channel_not_found'
    reassign_slack_username(user)
    retry unless (tries -= 1).zero?
  end

  def notify_users(users, message, attachment)
    users.each do |user|
      actionable_attachment = wrap_approver_actions(attachment, user)
      try_send(user, message, [actionable_attachment])
    end
  end

  def message_users(users, message, attachment)
    users.each do |user|
      try_send(user, message, [attachment])
    end
  end

  def message_channel(channel, message, attachment)
    @client.chat_postMessage(channel: "##{channel}", text: message, attachments: [attachment])
  end

  def wrap_approver_actions(attachment, user)
    actionable_attachment = attachment.dup
    actionable_attachment[:actions] = [
      {
        name: "act",
        text: "Approve",
        type: "button",
        style: "success",
        value: "approve"
      },
       {
        name: "act",
        text: "Reject",
        type: "button",
        style: "danger",
        value: "reject"
      }
    ]

    actionable_attachment
  end
end