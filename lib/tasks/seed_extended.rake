namespace :db do
  desc "Load extended seed data with 100 users and comprehensive feedback"
  task seed_extended: :environment do
    load Rails.root.join("db", "seeds_extended.rb")
  end
end
