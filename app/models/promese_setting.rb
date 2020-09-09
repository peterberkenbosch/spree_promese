class PromeseSetting < ActiveRecord::Base

  def self.instance
    self.class.first || self.class.create
  end

end
