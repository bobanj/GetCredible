desc "Calculates rank"
task :calculate_rank => :environment do
  rank_calculator = RankCalculator.new
  rank_calculator.calculate
end

