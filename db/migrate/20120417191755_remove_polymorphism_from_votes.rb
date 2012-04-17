class RemovePolymorphismFromVotes < ActiveRecord::Migration
  def up
    remove_index "votes", :name => "index_votes_on_voteable_id_and_voteable_type"
    remove_index "votes", :name => "fk_one_vote_per_user_per_entity", :unique => true
    remove_index "votes", :name => "index_votes_on_voter_id_and_voter_type"

    remove_column :votes, :voteable_type
    remove_column :votes, :voter_type

    add_index "votes", "voteable_id", :name => "index_votes_on_voteable_id"
    add_index "votes", ["voter_id", "voteable_id"], :name => "fk_one_vote_per_user_per_entity", :unique => true
    add_index "votes", "voter_id", :name => "index_votes_on_voter_id"
  end

  def down
    remove_index "votes", :name => "index_votes_on_voteable_id"
    remove_index "votes", :name => "fk_one_vote_per_user_per_entity"
    remove_index "votes", :name => "index_votes_on_voter_id"

    add_column :votes, :voter_type, :string
    add_column :votes, :voteable_type, :string

    add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
    add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
    add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"
  end
end
