# Umlaut Primo
[![Gem Version](https://badge.fury.io/rb/umlaut-primo.png)](http://badge.fury.io/rb/umlaut-primo)
[![Build Status](https://api.travis-ci.org/team-umlaut/umlaut-primo.png?branch=master)](https://travis-ci.org/team-umlaut/umlaut-primo)
[![Dependency Status](https://gemnasium.com/team-umlaut/umlaut-primo.png)](https://gemnasium.com/team-umlaut/umlaut-primo)
[![Code Climate](https://codeclimate.com/github/team-umlaut/umlaut-primo.png)](https://codeclimate.com/github/team-umlaut/umlaut-primo)
[![Coverage Status](https://coveralls.io/repos/team-umlaut/umlaut-primo/badge.png?branch=master)](https://coveralls.io/r/team-umlaut/umlaut-primo)

Umlaut services to provide full text service responses, holdings, etc. from the Primo discovery solution.

## Installation
In order to use the Umlaut Primo service, first 
[install Umlaut](https://github.com/team-umlaut/umlaut/wiki/Installation).
Then, in your Gemfile, add in the umlaut-primo gem, `gem 'umlaut-primo', '~> 0.1.0'`. 
Run `bundle intall` to get the Gem and then start your application as you normally would.

## Service Configuration
To use the Umlaut Primo services, they must be configured in `config/umlaut_service.yml`.
Two services are available for use, PrimoService and PrimoSource.

### PrimoService
The `PrimoService` is the basic Primo service for getting service data from Primo.

Several configurations parameters are available to be set in config/umlaut_services.yml.
A sample configuration is below.

     Primo: # Name of your choice
       type: PrimoService # Required
       priority: 2 # Required. I suggest running after the SFX service so you get the SFX referent enhancements
       base_url: http://primo.library.edu # Required
       vid: VID # Required
       institution: INST # Required
       holding_search_institution: SEARCH_INST # Optional. Defaults to the institution above.
       holding_search_text: Search for this title in Primo. # Optional text for holding search.  Defaults to "Search for this title."
       suppress_holdings: [ !ruby/regexp '/\$\$LWEB/', !ruby/regexp '/\$\$1Restricted Internet Resources/' ] # Optional
       ez_proxy: !ruby/regexp '/https\:\/\/ezproxy\.library\.edu\/login\?url=/' # Optional
       service_types: # Optional. Defaults to [ "fulltext", "holding", "holding_search", "table_of_contents", "referent_enhance" ]
         - holding
         - holding_search
         - fulltext
         - table_of_contents
         - referent_enhance
         - highlighted_link



### PrimoSource
The `PrimoSource` service depends on `PrimoService` and is used to expand Primo holdings based on information
from the data source.

Fi8rst, PrimoService must be configured with the `primo_source` service type instead of `holding`.

    Primo: # Name of your choice
      ...
      service_types:
        - primo_source
        - holding_search
        ...

Then you can configure the PrimoSource service in config/umlaut_services.yml

    PrimoSource: # Name of your choice
      type: PrimoSource # Required
      priority: 3 # Required. Must be run after PrimoService
      base_url: http://primo.library.edu # Required
      vid: VID # Required
      institution: INST # Required
      source_attributes: # Optional.
        - request_link_supports_ajax_call
        - requestability

## Primo Configuration
Primo offers several configuration options, specified in the Primo Back Office.
Since Umlaut doesn't have access to the Primo back office, the configurations need to be set in a separate file.
Umlaut Primo leverages the [exlibris-primo](https://github.com/scotdalton/exlibris-primo) gem which can set this configuration
via a YAML file.  Umlaut Primo expects this YAML file to be in `config/primo.yml`, but you can tell the PrimoService where the
YAML file is with the `primo_config` parameter.

A sample YAML config file would look like this:

    institutions:
      "primo_institution_code": "Primo Institution String"
    libraries:
      "primo_library_code": "Primo Library String"
    availability_statuses:
      "status1_code": "Status One"
    sources:
      data_source1:
        base_url: "http://source1.base.url
        type: source_type
        class_name: Source1Implementation (in exlibris/primo/sources or exlibris/primo/sources/local)
        source1_config_option1: source1_config_option1
          source1_config_option2: source1_config_option2
      data_source2:
        base_url: "http://source2.base.url
        type: source_type
        class_name: Source2Implementation (in exlibris/primo/sources or exlibris/primo/sources/local)
        source2_config_option1: source2_config_option1
        source2_config_option2: source2_config_option2