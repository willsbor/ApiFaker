module FakersHelper

    def setup_faker(faker)
        faker.build_api_prototype unless faker.api_prototypes.count > 0
        faker
    end
end
