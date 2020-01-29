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
    RIVER    = "~"
    COAST    = ")"
    MOUNTAIN = "^"
    PLAINS   = "_"
    FOREST   = "#"
    GRASSES  = ";"
    ISLAND   = "@"
    ISOLATED = "%"

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
    RUIN = "*"

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
    SEPARATOR = "|"

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

p Generator.name
p Generator.location { |location| location.has?(Filter::RIVER) }
