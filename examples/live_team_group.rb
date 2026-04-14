require 'bundler/setup'
require 'flipper'

live_feature = Flipper[:live_tab]

# Register the live_team group for early feature rollouts
Flipper.register(:live_team) do |actor|
  actor.respond_to?(:live_team_member?) && actor.live_team_member?
end

# User class that implements the live_team_member? method
class User
  attr_reader :id

  def initialize(id, live_team_member: false)
    @id = id
    @live_team_member = live_team_member
  end

  # Must respond to flipper_id
  alias_method :flipper_id, :id

  def live_team_member?
    @live_team_member == true
  end
end

live_team_user = User.new(1, live_team_member: true)
regular_user = User.new(2, live_team_member: false)

puts "Live Tab for live_team_user: #{live_feature.enabled?(live_team_user)}"
puts "Live Tab for regular_user: #{live_feature.enabled?(regular_user)}"

puts "\nEnabling Live Tab for live_team group...\n\n"
live_feature.enable_group :live_team

puts "Live Tab for live_team_user: #{live_feature.enabled?(live_team_user)}"
puts "Live Tab for regular_user: #{live_feature.enabled?(regular_user)}"
