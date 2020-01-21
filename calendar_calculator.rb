class PalanDate
    
    DAYS_PER_LUNAR_MONTH = 28/3r
    DAYS_PER_SOLAR_YEAR  = 1073/8r
    DAYS_PER_SEASON      = 44
    DAYS_PER_WEEK        = 4

    YEARS_PER_LEAP_YEAR  = 8
    SEASONS_PER_YEAR     = 4
    MIDSUMMER_SEASON     = 1

    LUNAR_PHASE_AT_ORIGIN = 1/3r
    SOLAR_PHASE_AT_ORIGIN = 0.5
    WEEKDAY_AT_ORIGIN     = 0

    WEEKDAY_NAMES = [
        "??? 1", 
        "??? 2", 
        "??? 3", 
        "??? 4", 
        "Midsummer 1", 
        "Midsummer 2", 
        "Midsummer Leap"
    ]

    WEEKDAY_NAMES_ABBR = [
        "1", 
        "2", 
        "3", 
        "4", 
        "Mid 1", 
        "Mid 2", 
        "Mid 3"
    ]

    SEASON_NAMES = [
        "Lenen",
        "Midsummer",
        "Feallan",
        "Wentruth"
    ]

    SEASON_NAMES_ABBR = [
        "Len",
        "Mid",
        "Feal",
        "Went"
    ]

    SEASON_SYMBOLS = [
        "/",
        "^",
        "\\",
        "_",
    ]

    attr_reader :year
    attr_reader :season
    attr_reader :day

    def self.leap_year?(year)
        return year % YEARS_PER_LEAP_YEAR == 0
    end

    def self.days_per_season(season, year)
        if season == MIDSUMMER_SEASON
            return leap_year?(year) ? 3 : 2
        else
            return DAYS_PER_SEASON
        end
    end

    def self.days_per_year(year)
        return leap_year?(year) ? DAYS_PER_SOLAR_YEAR.ceil : DAYS_PER_SOLAR_YEAR.floor
    end

    def initialize(year, season, day)
        if season < 0 or season >= SEASONS_PER_YEAR
            raise "Invalid season #{season}"
        end
        if day < 0 or day >= PalanDate.days_per_season(season, year)
            raise "Invalid day #{day}"
        end

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

    def season_name
        return SEASON_NAMES[@season]
    end

    def weekday
        if @season == MIDSUMMER_SEASON
            return (@day + WEEKDAY_AT_ORIGIN) + 4
        else
            return (@day + WEEKDAY_AT_ORIGIN) % DAYS_PER_WEEK
        end
    end

    def weekday_name
        return WEEKDAY_NAMES[self.weekday]
    end

    def year_day
        days = 0
        days += [*0...@season].sum { |season| PalanDate.days_per_season(season, @year) }
        days += self.day
        return days
    end

    def leap_year?
        return PalanDate.leap_year?(self.year)
    end

    def period_from(date)
        days = 0
        days += [*date.year...@year].sum { |year| PalanDate.days_per_year(@year) }
        days += [*date.season...@season].sum { |season| PalanDate.days_per_season(season, @year) }
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

    def to_s(format_string="%Y %h %d")
        string = format_string.dup
        string.gsub!("\%Y") { @year.to_s.rjust(4, "0") }
        string.gsub!("\%y") { @year }
        string.gsub!("\%m") { @season }
        string.gsub!("\%B") { self.season_name }
        string.gsub!("\%b") { SEASON_NAMES_ABBR[@season] }
        string.gsub!("\%h") { SEASON_SYMBOLS[@season] }
        string.gsub!("\%d") { @day + 1 }
        string.gsub!("\%j") { self.year_day }
        string.gsub!("\%A") { self.weekday_name }
        string.gsub!("\%a") { WEEKDAY_NAMES_ABBR[self.weekday] }
        string.gsub!("\%w") { self.weekday }
        return string
    end

    def self.parse(string)
        date_match = string.scan(/(\d+)\s*(#{SEASON_SYMBOLS.map{|i|"\\" + i}.join("|")})\s*(\d+)/)
        if date_match
            year, season, day = date_match[0]
            year = year.to_i
            season = SEASON_SYMBOLS.index(season)
            day = day.to_i - 1
            return PalanDate.new(year, season, day)
        end
        date_match = string.scan(/(\d+)\s*(#{SEASON_NAMES.join("|")})\s*(\d+)/)
        if date_match
            year, season, day = date_match[0]
            year = year.to_i
            season = SEASON_NAMES.index(season)
            day = day.to_i - 1
            return PalanDate.new(year, season, day)
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


a = PalanDate.new(1, 0, 39)

non_leap_year = PalanPeriod.new(PalanDate::DAYS_PER_SOLAR_YEAR.floor)
10.times do |i|
    d = a + non_leap_year * i
    p d
    puts d
    puts d.weekday_name
end

b = a.tomorrow.tomorrow.tomorrow.tomorrow.tomorrow
puts b
p b.weekday_name

c = PalanDate.parse(b.to_s)
puts c
