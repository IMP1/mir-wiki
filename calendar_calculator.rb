class PalanDate
    include Comparable
    
    DAYS_PER_LUNAR_MONTH = 28/3r   # 9.33...
    DAYS_PER_SOLAR_YEAR  = 1073/8r # 134.125
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
        if date > self
            while date != self
                date = date.yesterday
                days -= 1
            end
        else
            while date != self
                date = date.tomorrow
                days += 1
            end
        end
        return PalanPeriod.new(days)
    end

    def tomorrow
        day, season, year = @day, @season, @year
        day += 1
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
        day, season, year = @day, @season, @year
        day -= 1
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
            if date < self
                return period_from(date)
            else 
                return -date.period_from(self)
            end
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

    def <=>(date)
        if self.year != date.year
            return self.year <=> date.year
        end
        if self.season != date.season
            return self.season <=> date.season
        end
        if self.day != date.day
            return self.day <=> date.day
        end
        return 0
    end

    def to_s(format_string="<Date: %y, %m, %d>")
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

    def format(format_string)
        return to_s(format_string)
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
    include Comparable

    attr_reader :days

    def initialize(days)
        @days = days.to_i
    end

    def +(period)
        return PalanPeriod.new(@days + period.days)
    end

    def -(period)
        return PalanPeriod.new(@days - period.days)
    end

    def -@
        return PalanPeriod.new(-@days)
    end

    def /(period)
        return @days / period.days
    end

    def *(factor)
        return PalanPeriod.new(@days * factor)
    end

    def <=>(period)
        return @days <=> period.days
    end

    def to_s
        years = @days / PalanDate::DAYS_PER_SOLAR_YEAR

        if years.abs > 1
            remainder_days = @days % PalanDate::DAYS_PER_SOLAR_YEAR
            return "<Period: #{years.floor} years, #{remainder_days.round} days>"
        else 
            return "<Period: #{@days} days>"
        end
        return string
    end

end

def tests(n=10)
    success = true
    n.times do
        year = 100 + rand(30)
        season = rand(4)
        day = rand(PalanDate.days_per_season(season, year))
        origin = PalanDate.new(year, season, day)
        offset = PalanPeriod.new(rand(1000))
        past = origin - offset
        if past + offset != origin 
            puts "#{origin} - #{offset} + #{offset} != #{origin}"
            success = false
        end
        offset = PalanPeriod.new(rand(1000))
        future = origin + offset
        if future - offset != origin 
            puts "#{origin} + #{offset} - #{offset} != #{origin}"
            success = false
        end
    end
    return success
end

def print_date(date, prefix)
    print prefix.ljust(12) + " : "
    print date
    puts  date.format(" %Y %h (%B) %d")
end

def print_period(period, prefix)
    print prefix.ljust(12) + " : "
    puts period
end

def main
    today = PalanDate.parse("543 / 8")
    print_date(today, "Today's Date")

    yarrow_birth = PalanDate.parse("478 \\ 12")
    yarrow_age = today - yarrow_birth
    print_date(yarrow_birth, "Yarrow Birth")
    print_period(yarrow_age, "Yarrow Age")
    if yarrow_birth + yarrow_age != today
        puts "Yarrow birth + age is not right!"
    end

    salome_birth = PalanDate.parse("529 \\ 3")
    salome_age = today - salome_birth
    print_date(salome_birth, "Salome Birth")
    print_period(salome_age, "Salome Age")
    if salome_birth + salome_age != today
        puts "Salome birth + age is not right!"
    end

end

main