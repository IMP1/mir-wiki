=begin

Filters:

Race: 
    p = plainswalker
    m = midnighter
    d = delver
    g = dragonborn
    c = cephalopods
    u = ursalba

Geographical Features:
    ~ = River
    ) = Sea
    ^ = Mountain
    _ = Plains
    # = Forest
    @ = Island

Scale:
    = = town
    - = village
    . = settlement

Regions:
    B = ridgeback
    S = snow plains
    H = hillands
    R = roke
    F = frosthelm
    K = kingsooth
    E = estearth
    A = ashvale
    W = wetlands
    N = sand flats

=end

module Generator

    NAMES_FILENAME = "names.txt"
    SEPARATOR = "|"

    def self.name(parameters=nil)
        file_lines = File.readlines(NAMES_FILENAME)
        all_names = file_lines.map do |line| 
            name, filter, etymology = *line.split(SEPARATOR, 3)
            {name: name.capitalize, filter: filter.strip.split(//), etymology: etymology.strip}
        end
        filtered_names = all_names.select do |word|
            if parameters.nil? || parameters.empty? || word[:filter].include?("*")
                true
            elsif !(word[:filter] - parameters).empty?
                false
            else
                true
            end
        end
        p filtered_names
        random_name = filtered_names.sample
        return random_name
    end

    def self.origin(parameters=nil)
        file_lines = File.readlines("locations/index.rml")
        all_locations = file_lines.map.with_index { |line, i| [line, i] }.select { |line, i| line.include?("locations.push") }.map { |line, i| i }
        all_locations.map! do |line_index|
            # name: "Ridgeback",
            name = file_lines[line_index + 1][/name: "(.+)",/, 1]
            filter = []
            # scale: scale.continent,
            scale_text = file_lines[line_index + 2][/scale: scale\.(.+),/, 1]
            scale = case scale_text
            when "town"
                "="
            when "village"
                "-"
            when "settlement"
                "."
            when "island"
                "@"
            end
            # TODO: add whether a place is on a river, or on the sea, (etc.) somehow
            filter.push(scale)
            {name: name, filter: filter.compact}
        end
        filtered_locations = all_locations.select do |place|
            if parameters.nil? || parameters.empty
                true
            elsif !(place[:filter] - parameters).empty?
                false
            else
                true
            end
        end
    end

end

# puts Generator.name(["p"])
puts Generator.origin()