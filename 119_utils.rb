require 'rake'
require 'fileutils'
require 'common'
require 'find'

def act_on_java(root_path, &block)
    root = fix_path(root_path)
    Find.find(root).each do |file|
        if file.end_with? ".java"
            block.call(file)
        end
    end
end

def replace_legacy_mats(root_path)
    mats = {}
end

require "csv"
require 'json'
require "pp"

def gen_mats_list
    ids_to_mats = {}
    CSV.foreach(__dir__ + "/mats.csv") do |line|
        ids_to_mats[line[0]] = line[3]
    end
    legacy_to_new = {}
    CSV.foreach(__dir__ + "/legacy_mats.csv") do |line|
        raise "Can't find new name for " + line[0] if ids_to_mats[line[1]].nil?
        legacy_to_new[line[0]] = ids_to_mats[line[1]].upcase
    end
    File.open(__dir__ + "/items.json", 'w') do |f|
        f.write pp legacy_to_new.to_json
    end
end

def replace_legacy_mats(root_path)
    leg_to_new = JSON.parse(File.read(__dir__ + "/items.json"))
    act_on_java(root_path) do |file|
        contents = File.read(file)
        new_contents = contents

        leg_to_new.each do |k,v|
            new_contents = new_contents.gsub(/\b#{k}\b/, v)
        end

        if contents != new_contents
            File.open(file, "w") {|f| f.puts new_contents } 
        end
    end
end

def replace_legacy_stacks(root_path)
    act_on_java(root_path) do |file|
        contents = File.read(file)
        new_contents = contents.gsub(/\bItemStack\(Material.\b/, "ItemStack\(ItemTypes.")

        if contents != new_contents
            File.open(file, "w") {|f| f.puts new_contents } 
        end
    end
end

replace_legacy_mats("/Users/austinmayes/Projects/Java/Ziax 1.19/Core/CubeCraftCore/Core/Common/src/main/java/net/cubecraft/loot/items/cages/animations/halloween")
