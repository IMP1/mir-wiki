class PalanDate
    
    DAYS_PER_LUNAR_MONTH = 28/3r
    DAYS_PER_SOLAR_YEAR  = 1073/8r
    DAYS_PER_SEASON      = 44

    LUNAR_PHASE_AT_ORIGIN = 1/3r
    SOLAR_PHASE_AT_ORIGIN = 0.5

    YEARS_PER_LEAP_YEAR = 8

    SEASONS_PER_YEAR = 4

    SEASON_NAMES = [
        "Lenen",
        "Midsummer",
        "Feallan",
        "Wentruth"
    ]

    attr_reader :year
    attr_reader :season
    attr_reader :day

    def self.leap_year?(year)
        return year % YEARS_PER_LEAP_YEAR == 0
    end

    def self.days_per_season(season, year)
        if season == 1
            return leap_year?(year) ? 3 : 2
        else
            return DAYS_PER_SEASON
        end
    end

    def self.days_per_year(year)
        return leap_year?(year) ? DAYS_PER_SOLAR_YEAR.ceil : DAYS_PER_SOLAR_YEAR.floor
    end

    def initialize(year, season, day)
        @year = year
        @season = season
        @day = day
    end

    def to_days
        days = 0
        days += [*0...self.year].sum { |year| PalanDate.days_per_year(year) }
        days += [*0...self.season].sum { |season| PalanDate.days_per_season(season, year) }
        days += self.day
        return days
    end

    def lunar_phase
        days = self.to_days
        total_full_moons = LUNAR_PHASE_AT_ORIGIN + (days / DAYS_PER_LUNAR_MONTH)
        moon_phase = total_full_moons % 1
        return moon_phase
    end

    def leap_year?
        return PalanDate.leap_year?(self.year)
    end

    def period_from(date)
        days = 0
        days += [*date.year...self.year].sum { |year| PalanDate.days_per_year(year) }
        days += [*date.season...self.season].sum { |season| PalanDate.days_per_season(season, year) }
        days += self.day - date.day
        return PalanPeriod.new(days)
    end

    def tomorrow
        day = @day + 1
        season = @season
        year = @year
        if day >= PalanDate.days_per_season(@season, @year)
            day -= PalanDate.days_per_season(@season, @year)
            season += 1
        end
        if season >= SEASONS_PER_YEAR
            season -= SEASONS_PER_YEAR
            year += 1
        end
        return PalanDate.new(year, season, day)
    end

    def yesterday
        day = @day - 1
        season = @season
        year = @year
        if day < 0
            season -= 1
            day += PalanDate.days_per_season(season, @year)
        end
        if season < 0
            year -= 1
            season += SEASONS_PER_YEAR
        end
        return PalanDate.new(year, season, day)
    end

    def offset(period)
        date = self
        if period.days < 0
            period.days.abs.times do
                date = date.yesterday
            end
        else
            period.days.times do
                date = date.tomorrow
            end
        end
        return date
       
    end

    def -(date)
        if date.is_a?(PalanDate)
            return period_from(date)
        end
        if date.is_a?(PalanPeriod)
            return offset(-date)
        end
    end

    def +(period)
        if period.is_a?(PalanPeriod)
            return offset(period)
        end
    end

end

class PalanPeriod

    attr_reader :days

    def initialize(days)
        @days = days
    end

    def +(period)
        if period.is_a?(PalanPeriod)
            return PalanPeriod.new(@days + period.days)
        end
    end

    def -(period)
        if period.is_a?(PalanPeriod)
            return PalanPeriod.new(@days - period.days)
        end
    end

    def /(period)
        if period.is_a?(PalanPeriod)
            return @days / period.days
        end
    end

    def *(factor)
        if factor.is_a?(Numeric)
            return PalanPeriod.new(@days * factor)
        end
    end

end


a = PalanDate.new(10, 2, 20)
b = PalanDate.new(1, 2, 20)

period = a - b

p b
p period
p a
p b + period
p a.lunar_phase

non_leap_year = PalanPeriod.new(PalanDate::DAYS_PER_SOLAR_YEAR.floor)
p b + non_leap_year * 1
p b + non_leap_year * 2
p b + non_leap_year * 3
p b + non_leap_year * 4
p b + non_leap_year * 5
p b + non_leap_year * 6
p b + non_leap_year * 7
p b + non_leap_year * 8
p b + non_leap_year * 9

