class Cricketer < ApplicationRecord
  # Select players from the country 'Australia'
  scope :australian_players, -> { where(country: 'Australia') }

  # Select players with the role 'Batter'
  scope :batters, -> { where(role: 'Batter') }

  # Select players with the role 'Bowler'
  scope :bowlers, -> { where(role: 'Bowler') }

  # Sort players by the descending number of matches played
  scope :descending_by_matches, -> { order(matches: :desc) }

  # Batting average: Runs scored / (Number of innings in which player has been out)
  #
  # Note:
  # - If any of runs scored, innings batted and not outs are missing,
  #   return nil as the data is incomplete.
  # - If the player has not batted yet, return nil
  # - If the player has been not out in all innings, return runs scored.
  def batting_average
    return nil if runs_scored.nil? || innings_batted.nil? || not_out.nil?

    return runs_scored if innings_batted == not_out

    runs_scored.fdiv(innings_batted - not_out)
  end

  # Batting strike rate: (Runs Scored x 100) / (Balls Faced)
  #
  # Note:
  # - If any of runs scored and balls faced are missing, return nil as the
  #   data is incomplete
  # - If the player has not batted yet, return nil
  def batting_strike_rate
    return nil if runs_scored.nil? || balls_faced.nil? || balls_faced == 0

    (runs_scored * 100).fdiv(balls_faced)
  end

  # Create records for the classical batters
  def self.import_classical_batters
    Cricketer.create(
      name: 'Sachin Tendulkar',
      country: 'India',
      role: 'Batter',
      matches: 200,
      innings_batted: 329,
      not_out: 33,
      runs_scored: 15921,
      balls_faced: nil,
      high_score: 248,
      centuries: 51,
      half_centuries: 68
    )

    Cricketer.create(
      name: 'Rahul Dravid',
      country: 'India',
      role: 'Batter',
      matches: 164,
      innings_batted: 286,
      not_out: 32,
      runs_scored: 13288,
      balls_faced: 31258,
      high_score: 270,
      centuries: 36,
      half_centuries: 63
    )

    Cricketer.create(
      name: 'Kumar Sangakkara',
      country: 'Sri Lanka',
      role: 'Wicketkeeper',
      matches: 134,
      innings_batted: 233,
      not_out: 17,
      runs_scored: 12400,
      balls_faced: 22882,
      high_score: 319,
      centuries: 38,
      half_centuries: 52
    )

    Cricketer.create(
      name: 'Ricky Ponting',
      country: 'Australia',
      role: 'Batter',
      matches: 168,
      innings_batted: 287,
      not_out: 29,
      runs_scored: 13378,
      balls_faced: 22782,
      high_score: 257,
      centuries: 41,
      half_centuries: 62
    )

    Cricketer.create(
      name: 'Brian Lara',
      country: 'West Indies',
      role: 'Batter',
      matches: 131,
      innings_batted: 232,
      not_out: 6,
      runs_scored: 11953,
      balls_faced: 19753,
      high_score: 400,
      centuries: 34,
      half_centuries: 48
    )
  end

  # Update the current data with an innings scorecard.
  #
  # A batting_scorecard is defined an array of the following type:
  # [Player name, Is out, Runs scored, Balls faced, 4s, 6s]
  #
  # For example:
  # [
  #   ['Rohit Sharma', true, 26, 77, 3, 1],
  #   ['Shubham Gill', true, 50, 101, 8, 0],
  #   ...
  #   ['Jasprit Bumrah', false, 0, 2, 0, 0],
  #   ['Mohammed Siraj', true, 6, 10, 1, 0]
  # ]
  #
  # There are atleast two batters and upto eleven batters in an innings.
  #
  # A bowling_scorecard is defined as an array of the following type:
  # [Player name, Balls bowled, Maidens bowled, Runs given, Wickets]
  #
  # For example:
  # [
  #   ['Mitchell Starc', 114, 7, 61, 1],
  #   ['Josh Hazzlewood', 126, 10, 43, 2],
  #   ...
  #   ['Cameron Green', 30, 2, 11, 0]
  # ]
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception with the player's name as
  # the message.
  def self.update_innings(batting_scorecard, bowling_scorecard)
    batting_scorecard.each do |row|
      player = Cricketer.find_by(name: row[0])

      raise ActiveRecord::RecordNotFound, row[0] if player.nil?

      player.not_out += 1 if !row[1]

      player.runs_scored += row[2]
      player.high_score = row[2] if row[2] > player.high_score

      if row[2] >= 100
        player.centuries += 1
      elsif row[2] >= 50
        player.half_centuries += 1
      end

      player.innings_batted += 1 if row[3]
      player.balls_faced += row[3]

      player.fours_scored += row[4]
      player.sixes_scored += row[5]

      player.save
    end

    bowling_scorecard.each do |row|
      player = Cricketer.find_by(name: row[0])

      raise ActiveRecord::RecordNotFound, row[0] if player.nil?

      player.innings_bowled += 1
      player.balls_bowled += row[1]
      player.runs_given += row[3]
      player.wickets_taken += row[4]

      player.save
    end
  end

  # Delete the record associated with a player.
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception.
  def self.ban(name)
    player = Cricketer.find_by(name: name)

    raise ActiveRecord::RecordNotFound, name if player.nil?

    player.destroy
  end
end
