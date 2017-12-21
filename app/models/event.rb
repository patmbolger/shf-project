class Event
  # Execute business actions that occur after an application "event".
  # Actions can include notification, audit/history recording, updating
  # related entities and similar, but not neccessarily limited to those actions.

  # This aggregates all post-event actions so they can be viewed in context.

  # Example events include 1) a new app is received, 2) app is accepted,
  # 3) membership payment received, etc.

  TYPE = { MEMBERSHIP_PAID: :membership_paid,
           NEW_APPLICATION: :new_shf_application_received }

  def self.create(evt_type, evt_data={})
    Event.send(evt_type, evt_data)
  end

  def self.membership_paid(evt_data)
    # evt_data[:user_id] == user_id
    # Business rules:
    # 1. Invoke method to determine whether to grant membership
    # NOTE: we could send the ack email here or in model

    user = User.find(evt_data[:user_id])
    user.grant_membership
  end
  

  def self.new_shf_application_received(evt_data) # EXAMPLE - NOT IN USE
    # evt_data[:application] == new SHF application
    # Business rules:
    # 1. Send ACK email to applicant
    # 2. Send notify email to all admins

    ShfApplicationMailer.acknowledge_received(evt_data[:application]).deliver_now

    User.admins.each do |admin|
      AdminMailer.new_shf_application_received(evt_data[:application], admin).deliver_now
    end
  end

end
