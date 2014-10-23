# == Overview
# PrimoSource is a PrimoService that converts primo_source service types into Primo source holdings.
# This mechanism allows linking to original data sources and their holdings information
# based on the given Primo sources and can be implemented per source.
#
# PrimoSources are not necessary to use the Primo service andthey require programming.
# They do, however, allow further customization and functionality.
#
# == Prerequisites
# First, the PrimoService must be configured with the primo_source service type instead of holding.
#
#   Primo: # Name of your choice
#     type: PrimoService
#     ...
#     service_types:
#       - primo_source
#       - holding_search
#       ...
#
# ==Available Parameters
# Several configurations parameters are available to be set in config/umlaut_services.yml.
#   PrimoSource: # Name of your choice
#     type: PrimoSource # Required
#     priority: 3 # Required. Must be run after PrimoService
#     base_url: http://primo.library.edu # Required
#     vid: VID # Required
#     institution: INST # Required
#     source_attributes: # Optional.
#       - request_link_supports_ajax_call
#       - requestability
#
# base_url:: _required_ host and port of Primo server for Primo display deep link
# vid:: _required_ view id for Primo display deep link
# institution:: _required_ institution id for Primo display deep link
# source_attributes::  _optional_ Array of Holding attribute readers to persist to
#   holding service_data; can be used to save custom source implementation attributes
#   for display by a custom holding partial
#
class PrimoSource < PrimoService

  # Overwrites PrimoService#new.
  def initialize(config)
    @service_types = ["holding"]
    @source_attributes = []
    super(config)
  end

  # Overwrites PrimoService#handle.
  def handle(request)
    primo_sources = request.get_service_type('primo_source', {:refresh => true})
    sources = [] # for de-duplicating holdings from catalog.
    primo_sources.each do |primo_source|
      # Call PrimoService#to_primo_source with the ServiceResponse
      source = primo_source.service.to_primo_source(primo_source)
      # There are some cases where source records may need to be de-duplicated against existing records
      # Check if we've already seen this record.
      next if sources.include?(source)
      # Include the source so that it's available for deduping
      sources << source
      # There may be multiple holdings mapped to one availlibrary here,
      # so we get the additional holdings and add them.
      source.expand.each do |holding|
        service_data = {}
        @holding_attributes.each do |attr|
          service_data[attr] = holding.send(attr.to_sym) if holding.respond_to?(attr.to_sym)
        end
        @source_attributes.each do |attr|
          service_data[attr.to_sym] = holding.send(attr.to_sym) if holding.respond_to?(attr.to_sym)
        end
        service_data.merge!({
          :url => (holding.respond_to? :url) ? holding.url : deep_link_display_url(holding),
          :collection_str => "#{holding.library} #{holding.collection}",
          :coverage_str => holding.coverage.join("<br />"),
          :coverage_str_array => holding.coverage,
          # :expired determines whether we show the holding in this service
          # Since this is fresh, the data has not yet expired.
          :expired => false,
          # :latest determines whether we show the holding in other services, e.g. txt and email.
          # It persists for one more cycle than :expired so services that run after
          # this one, but in the same resolution request have access to the latest holding data.
          :latest => true })
        request.add_service_response(
          service_data.merge(:service=>self,
            :service_type_value => "holding" ))
      end
    end
    return request.dispatched(self, true)
  end
end
