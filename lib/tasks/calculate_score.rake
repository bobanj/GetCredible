desc "Calculates rank"
task :calculate_score => :environment do
  rank_calculator = ScoreCalculator.new
  rank_calculator.calculate
end

