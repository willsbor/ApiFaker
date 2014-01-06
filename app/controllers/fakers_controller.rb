# encoding: utf-8

class FakersController < ApplicationController

    def index
        @fakers = Faker.all
    end

    def new
        @faker = Faker.new
        #先建立一個
        @apiPrototype = ApiPrototype.new(:prototype => 'please input JSON', :faker_id => @faker.id)
    end

    def create
        # {"utf8"=>"✓", "authenticity_token"=>"Q+F147FBm4nStjIL4yJxLbkGdztNLrEsdwpWTjBO5yc=", 
        #   "faker"=>{"api"=>"", "api_prototype"=>{"prototype"=>"please input JSON"}}, 
        #   "commit"=>"Create", "action"=>"create", "controller"=>"fakers"}
        @faker = Faker.new()
        @faker.api = params[:faker][:api]
        @faker.save

        @apiPrototype = ApiPrototype.new()
        @apiPrototype.prototype = params[:faker][:api_prototype][:prototype]
        @apiPrototype.faker_id = @faker.id
        @apiPrototype.save

        flash[:notice] = "建立成功"
        redirect_to :action => :index
    end

    def edit
        @faker = Faker.find(params[:id])
        aps = @faker.api_prototypes
        if aps.count > 0
            @apiPrototype = aps[0]
        else
            @apiPrototype = ApiPrototype.new()
            @apiPrototype.faker_id = @faker.id
            @apiPrototype.save
        end
        
    end

    def update
        # {"utf8"=>"✓", "authenticity_token"=>"Q+F147FBm4nStjIL4yJxLbkGdztNLrEsdwpWTjBO5yc=", 
        #  "faker"=>{"api"=>"api/user3", 
        #            "api_prototype"=>{"id"=>"4", "prototype"=>"{\"#fake_type#\":\"array\",\"min\":2,\"max\":10,\"#fake_item#\":{\"id\":{\"#fake_type#\":\"integer\", \"min\":1},\"name\":{\"#fake_type#\":\"string\",\"min\":2,\"max\":4},\"money\":{\"#fake_type#\":\"integer\",\"min\":1}, \"fixvalue\": \"abc\"}}"}}, 
        #  "commit"=>"Update", "id"=>"4"}
        @faker = Faker.find(params[:id])
        @faker.update_attributes(faker_update_params)
        @apiPrototype = ApiPrototype.find(params[:faker][:api_prototype][:id])
        @apiPrototype.update_attributes(faker_api_prototype_update_params)

        flash[:notice] = "更新成功"
        redirect_to :action => :index
    end

    def destroy
        @faker = Faker.find(params[:id])
        @faker.destroy

        redirect_to :action => :index
    end

    def apply

        #params[:format] = "html"

        # 查詢對應的 api
        api = params[:api];
        api << ".#{params[:format]}" if params[:format]
        @fakers = Faker.where([ "api = ?", api ])

        # 選取第一個
        @faker = @fakers.first

        # prototypes & 拿取第一個 prototype
        #@faker_prototypes = ApiPrototype.where([ "faker_id = ?", @faker[:id] ])
        @faker_prototypes = @faker.api_prototypes
        @faker_prototypes_default = @faker_prototypes.first

        @result_json_string = @faker_prototypes_default.prototype
        @result_json = JSON.parse(@result_json_string)

        # 改用JSON
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

        #respond_to do |format|
  #format.html {  }
  #format.all {render :action => "index.html.erb", :content_type => "text/html"}
  #format.any() { redirect_to(person_list_url) }
        #end
        render :json => @result_json
        #render :action => "apply.html.erb"
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

    def faker_update_params
        params[:faker].slice(:api)
    end

    def faker_api_prototype_update_params
        params[:faker][:api_prototype].slice(:prototype)
    end
end
