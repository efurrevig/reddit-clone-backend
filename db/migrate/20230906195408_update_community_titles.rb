class UpdateCommunityTitles < ActiveRecord::Migration[7.0]

  def up
    Community.find_each do |community|
      community.update(title: community.name)
    end
  end

end
