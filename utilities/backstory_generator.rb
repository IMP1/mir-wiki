require 'ostruct'

module Filter

    # Races
    PLAINSWALKER = "p"
    MIDNIGHTER   = "m"
    DELVER       = "d"
    DRAGONBORN   = "g"
    CEPHALOPODS  = "c"
    URSALBA      = "u"

    # Geographical Features
    RIVER       = "~"
    COAST       = ")"
    MOUNTAIN    = "^"
    UNDERGROUND = "]"
    PLAINS      = "_"
    FOREST      = "#"
    GRASSES     = ";"
    ISLAND      = "@"
    ISOLATED    = "%"
    SNOW        = "*"
    OCEAN       = "}"

    # Race Features
    CARNIVORE = "1"
    HERBIVORE = "2"
    SENTIENT  = "3"
    SAPIENT   = "4"
    VERBAL    = "5"
    BIPEDAL   = "6"

    # Regions
    RIDGEBACK   = "B"
    SNOW_PLAINS = "S"
    HILLANDS    = "H"
    ROKE        = "R"
    FROSTHELM   = "F"
    KINGSOOTH   = "K"
    ESTEARTH    = "E"
    ASHVALE     = "A"
    WETLANDS    = "W"
    SAND_FLATS  = "N"

    # Geographical Scale
    TOWN       = "="
    VILLAGE    = "-"
    SETTLEMENT = "."

    # Other Features
    RUIN = "¬"

end

class Name

    def initialize(name, etymology, races)
        @name = name
        @etymology = etymology
        @races = races
    end

    def race?(race)
        @races.include?(race)
    end

    def to_s
        @name
    end

end

class Race

    attr_reader :code

    def initialize(name, constant, filter)
        @name = name
        @code = constant
        @filter = filter
    end

    def marine?
        return has_feature?(Filter::WATER)
    end

    def sapient?
        return has_feature?(Filter::SAPIENT)
    end

    def human?
        return has_feature?(Filter::BIPEDAL) && sapient?
    end

    def has_feature?(location)
        return @filter.include?(location)
    end

    alias :found_in? :has_feature?

end

class Location

    attr_reader :name
    attr_reader :scale
    attr_reader :region
    attr_reader :continent
    attr_reader :features

    def initialize(name, scale, region, continent, features)
        @name = name
        @scale = scale
        @region = region
        @continent = continent
        @features = features
    end

    def town?
        return @scale == Filter::TOWN
    end

    def village?
        return @scale == Filter::VILLAGE
    end

    def settlement?
        return @scale == Filter::SETTLEMENT
    end

    def region?(region)
        return @region == region
    end

    def continent?(continent)
        return @continent == continent
    end

    def populated?
        return !@features.include?(Filter::RUIN)
    end

    def has?(feature)
        return @features.include?(feature)
    end

    def to_s
        @name
    end

end

module Generator

    NAMES_FILENAME = "names.txt"
    LOCATIONS_FILENAME = "locations.txt"
    RACES_FILENAME = "races.txt"
    SEPARATOR = "|"

    def self.race(&filter)
        file_lines = File.readlines(File.join(__dir__, RACES_FILENAME))
        all_races = file_lines.map do |line| 
            name, features = *line.split(SEPARATOR, 3).map { |item| item.strip }
            code = Filter.const_get(name.to_sym)
            Race.new(name.capitalize, code, features.split(//))
        end
        filtered_races = filter.nil? ? all_races : all_races.select(&filter)
        random_race = filtered_races.sample
        return random_race
    end

    def self.name(&filter)
        file_lines = File.readlines(File.join(__dir__, NAMES_FILENAME))
        all_names = file_lines.map do |line| 
            name, races, etymology = *line.split(SEPARATOR, 3).map { |item| item.strip }
            Name.new(name.capitalize, etymology, races.split(//))
        end
        filtered_names = filter.nil? ? all_names : all_names.select(&filter)
        random_name = filtered_names.sample
        return random_name
    end

    def self.location(&filter)
        file_lines = File.readlines(File.join(__dir__, LOCATIONS_FILENAME))
        all_locations = file_lines.map do |line|
            name, scale, region, continent, features = *line.split(SEPARATOR, 5).map { |item| item.strip }
            Location.new(name.capitalize, scale, region, continent, features.split(//))
        end
        filtered_locations = filter.nil? ? all_locations : all_locations.select(&filter)
        random_location = filtered_locations.sample
        return random_location
    end

end

p Generator.name { |name| name.race?(Filter::PLAINSWALKER) }
p Generator.location { |location| location.has?(Filter::RIVER) }
p Generator.race { |race| race.human? && race.found_in?(Filter::MOUNTAIN) }
