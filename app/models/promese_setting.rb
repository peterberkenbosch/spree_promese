class PromeseSetting < ActiveRecord::Base

  def self.instance
    self.first || self.create
  end

end
