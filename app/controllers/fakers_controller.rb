# encoding: utf-8

class FakersController < ApplicationController
    def index

        # 查詢對應的 api
        @fakers = Faker.where([ "api = ?", params[:api] ])

        # 選取第一個
        @faker = @fakers.first

        # prototypes & 拿取第一個 prototype
        #@faker_prototypes = ApiPrototype.where([ "faker_id = ?", @faker[:id] ])
        @faker_prototypes = @faker.api_prototypes
        @faker_prototypes_default = @faker_prototypes.first

        @result_json_string = @faker_prototypes_default.prototype
        @result_json = JSON.parse(@result_json_string)

        # 改用JSON
        # {"id":{"#fake_type#":"integer", "min":1},"name":{"#fake_type#":"string","min":2,"max":4},"money":{"#fake_type#":"integer",min":1}}

        result_json_replaced = replace_fake_data(@result_json)
        @result_json = result_json_replaced if result_json_replaced

        # 取代數字
        #@result_json = @result_json.gsub(/#integer:.*?#/) do |s|
        #    param = s[/#integer:(.*?)#/, 1]
        #    replace_integer(param)
        #end

        # 取代string
        #@result_json = @result_json.gsub(/#string:.*?#/) do |s|
        #    param = s[/#string:(.*?)#/, 1]
        #    replace_string(param)
        #end
    end

    protected

    def replace_fake_data (json)
        json = json.clone
        if json.kind_of?(Array)
            json.each_index do |i|
                value = json[i]
                nvalue = replace_fake_data(value)
                json[i] = nvalue if nvalue
            end
            json
        elsif json.kind_of?(Hash)
            if json.has_key?("#fake_type#")
                fake_type = json["#fake_type#"]
                if fake_type == "integer"
                    nvalue = replace_integer(json)
                elsif fake_type == "string"
                    nvalue = replace_string(json)
                elsif fake_type == "array"
                    nvalue = replace_array(json)
                end
            else
                json.keys.each do |key|
                    value = json[key]
                    nvalue = replace_fake_data(value)
                    json[key] = nvalue if nvalue
                end
                json
            end
        end
    end

    def replace_integer (parsed)
        parsed = JSON.parse(parsed) if parsed.kind_of?(String)
        min = 0
        min = parsed["min"] if parsed.has_key?("min")
        max = 32767
        max = parsed["max"] if parsed.has_key?("max")
        prng = Random.new
        prng.rand(min..max)
    end

    def replace_string (parsed)
        parsed = JSON.parse(parsed) if parsed.kind_of?(String)
        min = 0
        min = parsed["min"] if parsed.has_key?("min")
        max = 32767
        max = parsed["max"] if parsed.has_key?("max")

        prng = Random.new
        len = prng.rand(min..max)
        strings = ''
        File.open("public/string_candidate_default.txt", "r") do |f|
            oneline = f.gets
            len = oneline.length if oneline.length < len
            strings << oneline[0..(len - 1)]
        end
        strings << ''
    end

    def replace_array (parsed)
        parsed = JSON.parse(parsed) if parsed.kind_of?(String)
        min = 0
        min = parsed["min"] if parsed.has_key?("min")
        max = 32767
        max = parsed["max"] if parsed.has_key?("max")
        prng = Random.new
        len = prng.rand(min..max)

        itemProto = parsed["#fake_item#"]
        ary = Array.new(len)
        ary.each_index do |i|
            ary[i] = replace_fake_data(itemProto)
        end
    end
end
