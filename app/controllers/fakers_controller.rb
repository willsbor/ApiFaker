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

        @result_json = @faker_prototypes_default.prototype
        # 取代數字
        @result_json = @result_json.gsub(/#integer:.*?#/) do |s|
            param = s[/#integer:(.*?)#/, 1]
            replace_integer(param)
        end

        # 取代string
        @result_json = @result_json.gsub(/#string:.*?#/) do |s|
            param = s[/#string:(.*?)#/, 1]
            replace_string(param)
        end
    end

    protected

    def replace_integer (json)
        parsed = JSON.parse(json)
        min = 0
        min = parsed["min"] if parsed.has_key?("min")
        max = 32767
        max = parsed["max"] if parsed.has_key?("max")
        prng = Random.new
        prng.rand(min..max)
    end

    def replace_string (json)
        parsed = JSON.parse(json)
        min = 0
        min = parsed["min"] if parsed.has_key?("min")
        max = 32767
        max = parsed["max"] if parsed.has_key?("max")

        prng = Random.new
        len = prng.rand(min..max)
        strings = '"'
        File.open("public/string_candidate_default.txt", "r") do |f|
            oneline = f.gets
            len = oneline.length if oneline.length < len
            strings << oneline[0..(len - 1)]
        end
        strings << '"'
    end

end
