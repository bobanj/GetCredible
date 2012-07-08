desc "Calculates rank"
task :calculate_score => :environment do
  desc "Calculates Score in the system"
  rank_calculator = ScoreCalculator.new
  rank_calculator.calculate
end

