# encoding: UTF-8
require 'test_helper'
require 'fileutils'
class PrimoServiceTest < ActiveSupport::TestCase
  fixtures :requests, :referents, :referent_values, :sfx_urls

  setup do
    @base_url = "http://bobcat.library.nyu.edu"
    @vid = "VID"
    @institution = "NYU"
    @holding_search_institution = "NYU"
    @holding_search_text = "Search for this title in BobCat."
    @holding_search_institution = "NYU"
    @primo_minimum = PrimoService.new({
      "priority"=>1, "service_id" => "Primo",
      "base_url" => @base_url, "vid" => @vid, "institution" => @institution,
      "holding_search_institution" => @holding_search_institution })
    @primo_old_minimum = PrimoService.new({
      "priority"=>1, "service_id" => "Primo",
      "base_path" => @base_url, "base_view_id" => @vid, "institution" => @institution })
    @primo_minimum_no_config = PrimoService.new({
      "priority"=>1, "service_id" => "Primo",
      "base_url" => @base_url, "vid" => @vid, "institution" => @institution,
      "holding_search_institution" => @holding_search_institution,
      "primo_config" => "missing_config.yml" })
    @primo_service = ServiceStore.instantiate_service!("Primo", nil)
  end

  test "missing primo config" do
    @primo_minimum.send(:reset_primo_config)
    FileUtils.mv(PrimoService.default_config_file, "#{PrimoService.default_config_file}.bak")
    assert_nothing_raised {
      PrimoService.new({
        "priority"=>1, "service_id" => "Primo",
        "base_url" => @base_url, "vid" => @vid, "institution" => @institution,
        "holding_search_institution" => @holding_search_institution})
    }
    FileUtils.mv("#{PrimoService.default_config_file}.bak", PrimoService.default_config_file)
  end

  test "minimum config request by id" do
    request = requests(:travels_with_my_aunt_by_id)
    VCR.use_cassette("travels with my by id") do
      @primo_minimum.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.referent.referent_values.reset
    request.dispatched_services.reset
    request.service_responses.reset

    # Test that the referent was enhanced
    assert_equal("Greene", request.referent.metadata["aulast"])
    assert_equal("Graham,", request.referent.metadata["aufirst"])
    assert_equal("Greene, Graham, 1904-1991", request.referent.metadata["au"])
    assert_equal("Travels with my aunt", request.referent.metadata["title"])
    assert_equal("Travels with my aunt", request.referent.metadata["btitle"])
    assert_equal("New York", request.referent.metadata["place"])
    assert_equal("Penguin Books", request.referent.metadata["pub"])
    assert_equal("56781200", request.referent.metadata["oclcnum"])
    assert_equal("2004559272", request.referent.metadata["lccn"])

    # Get the returned holdings service responses
    holdings = request.get_service_type('holding')
    # Should only be 1 holding service response
    assert_equal(1, holdings.length)
    # Get the holding service response view data
    view_data = holdings.first.view_data
    # Test the holding service response view data
    assert_equal("aleph000062856", view_data[:record_id])
    assert_equal("aleph", view_data[:source_id])
    assert_equal("NYU01", view_data[:original_source_id])
    assert_equal("000062856", view_data[:source_record_id])
    assert_equal("NYU", view_data[:institution_code])
    assert_equal("NYU", view_data[:institution])
    assert_equal("BOBST", view_data[:library_code])
    assert_equal("NYU Bobst", view_data[:library])
    assert_equal("check_holdings", view_data[:status_code])
    assert_equal("Check Availability", view_data[:status])
    assert_equal("Main Collection", view_data[:collection])
    assert_equal("(PR6013.R44 T7 2004 )", view_data[:call_number])
    assert_equal(nil, view_data[:origin])
    assert_equal("book", view_data[:display_type])
    assert_equal([], view_data[:coverage])
    assert_equal({}, view_data[:source_data])
    assert_equal("#{@base_url}/primo_library/libweb/action/dlDisplay.do?docId=aleph000062856&institution=NYU&vid=#{@vid}", view_data[:url])
    assert_equal(nil, view_data[:request_url])
    assert_equal(ServiceResponse::MatchExact, view_data[:match_reliability])

    # Get the returned table of contents service responses
    tables_of_contents = request.get_service_type('table_of_contents')
    # Should only be 1 table of contents service response
    assert_equal(1, tables_of_contents.length)
    assert_equal("https://ezproxy.library.edu/login?url=http://dummy.toc.com", tables_of_contents.first.url)
    assert_equal("Dummy Table of Contents", tables_of_contents.first.display_text)
    # Get the table of contents service response view data
    view_data = tables_of_contents.first.view_data
    assert_equal("aleph000062856", view_data[:record_id])
    assert_equal("aleph000062856", view_data[:original_id])
    assert_equal("Dummy Table of Contents", view_data[:display])
  end

  test "no config request by id" do
    request = requests(:travels_with_my_aunt_by_id)
    @primo_minimum_no_config.send(:reset_primo_config)
    VCR.use_cassette("travels with my by id") do
      @primo_minimum_no_config.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.referent.referent_values.reset
    request.dispatched_services.reset
    request.service_responses.reset

    # Test that the referent was enhanced
    assert_equal("Greene", request.referent.metadata["aulast"])
    assert_equal("Graham,", request.referent.metadata["aufirst"])
    assert_equal("Greene, Graham, 1904-1991", request.referent.metadata["au"])
    assert_equal("Travels with my aunt", request.referent.metadata["title"])
    assert_equal("Travels with my aunt", request.referent.metadata["btitle"])
    assert_equal("New York", request.referent.metadata["place"])
    assert_equal("Penguin Books", request.referent.metadata["pub"])
    assert_equal("56781200", request.referent.metadata["oclcnum"])
    assert_equal("2004559272", request.referent.metadata["lccn"])

    # Get the returned holdings service responses
    holdings = request.get_service_type('holding')
    # Should only be 1 holding service response
    assert_equal(1, holdings.length)
    # Get the holding service response view data
    view_data = holdings.first.view_data
    # Test the holding service response view data
    assert_equal("aleph000062856", view_data[:record_id])
    assert_equal("aleph", view_data[:source_id])
    assert_equal("NYU01", view_data[:original_source_id])
    assert_equal("000062856", view_data[:source_record_id])
    assert_equal("NYU", view_data[:institution_code])
    assert_equal("NYU", view_data[:institution])
    assert_equal("BOBST", view_data[:library_code])
    assert_equal("BOBST", view_data[:library])
    assert_equal("check_holdings", view_data[:status_code])
    assert_equal("check_holdings", view_data[:status])
    assert_equal("Main Collection", view_data[:collection])
    assert_equal("(PR6013.R44 T7 2004 )", view_data[:call_number])
    assert_equal(nil, view_data[:origin])
    assert_equal("book", view_data[:display_type])
    assert_equal([], view_data[:coverage])
    assert_equal({}, view_data[:source_data])
    assert_equal("#{@base_url}/primo_library/libweb/action/dlDisplay.do?docId=aleph000062856&institution=NYU&vid=#{@vid}", view_data[:url])
    assert_equal(nil, view_data[:request_url])
    assert_equal(ServiceResponse::MatchExact, view_data[:match_reliability])
  end

  test "legacy config request by id" do
    request = requests(:travels_with_my_aunt_by_id)
    VCR.use_cassette("travels with my by id") do
      @primo_old_minimum.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.referent.referent_values.reset
    request.dispatched_services.reset
    request.service_responses.reset

    # Test that the referent was enhanced
    assert_equal("Greene", request.referent.metadata["aulast"])
    assert_equal("Graham,", request.referent.metadata["aufirst"])
    assert_equal("Greene, Graham, 1904-1991", request.referent.metadata["au"])
    assert_equal("Travels with my aunt", request.referent.metadata["title"])
    assert_equal("Travels with my aunt", request.referent.metadata["btitle"])
    assert_equal("New York", request.referent.metadata["place"])
    assert_equal("Penguin Books", request.referent.metadata["pub"])
    assert_equal("56781200", request.referent.metadata["oclcnum"])
    assert_equal("2004559272", request.referent.metadata["lccn"])

    # Get the returned holdings service responses
    holdings = request.get_service_type('holding')
    # Should only be 1 holding service response
    assert_equal(1, holdings.length)
    # Get the holding service response view data
    view_data = holdings.first.view_data
    # Test the holding service response view data
    assert_equal("aleph000062856", view_data[:record_id])
    assert_equal("aleph", view_data[:source_id])
    assert_equal("NYU01", view_data[:original_source_id])
    assert_equal("000062856", view_data[:source_record_id])
    assert_equal("NYU", view_data[:institution_code])
    assert_equal("NYU", view_data[:institution])
    assert_equal("BOBST", view_data[:library_code])
    assert_equal("NYU Bobst", view_data[:library])
    assert_equal("check_holdings", view_data[:status_code])
    assert_equal("Check Availability", view_data[:status])
    assert_equal("Main Collection", view_data[:collection])
    assert_equal("(PR6013.R44 T7 2004 )", view_data[:call_number])
    assert_equal(nil, view_data[:origin])
    assert_equal("book", view_data[:display_type])
    assert_equal([], view_data[:coverage])
    assert_equal({}, view_data[:source_data])
    assert_equal("#{@base_url}/primo_library/libweb/action/dlDisplay.do?docId=aleph000062856&institution=NYU&vid=#{@vid}", view_data[:url])
    assert_equal(nil, view_data[:request_url])
    assert_equal(ServiceResponse::MatchExact, view_data[:match_reliability])
  end

  test "expired dedupmgr record" do
    request = requests(:digital_futures_living_in_a_dot_com_world)
    VCR.use_cassette("digital_futures_living_in_a_dot_com_world", match_requests_on: [:body]) do
      @primo_service.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.dispatched_services.reset
    request.service_responses.reset

    # Get the returned fulltext service responses
    fulltexts = request.get_service_type('fulltext')

    assert_not_empty(fulltexts)
  end

  test "sfx owner but fulltext empty" do
    request = requests(:australian_journal_of_international_affairs_by_id)
    VCR.use_cassette("australian journal of international affairs by id") do
      @primo_service.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.dispatched_services.reset
    request.service_responses.reset

    # Get the returned fulltext service responses
    fulltexts = request.get_service_type('fulltext')
    # Remove the ezproxy url
    url = @primo_service.send(:handle_ezproxy, fulltexts.first.url)
    assert(SfxUrl.sfx_controls_url?(url))
    assert_equal(6, fulltexts.length)
    fulltext = fulltexts.first
    assert_equal("https://ezproxy.library.edu/login?url=http://proquest.umi.com/pqdweb?RQT=318&VName=PQD&clientid=9269&pmid=34445", fulltext.url )
    assert_equal("1997 - 2000 Full Text available from ProQuest", fulltext.display_text )
    # Get the fulltext service response view_data
    view_data = fulltext.view_data
    assert_equal("dedupmrg17737330", view_data[:record_id])
    assert_equal("aleph000935132", view_data[:original_id])
    assert_equal("1997 - 2000 Full Text available from ProQuest", view_data[:display])
  end

  test "issn search with no title" do
    request = requests(:russkaia_pochta_with_no_title_by_issn)
    # Make sure the referent values are nil to start with
    assert_nil(request.referent.title, "Title was not nil before resolving by ISSN.")
    assert_nil(request.referent.metadata["jtitle"], "Journal title was not nil before resolving by ISSN.")
    assert_nil(request.referent.metadata["place"], "Publication place was not nil before resolving by ISSN.")
    assert_nil(request.referent.metadata["pub"], "Publisher was not nil before resolving by ISSN.")
    assert_nil(request.referent.metadata["oclcnum"], "OCLC number was nil before resolving by ISSN.")
    assert_nil(request.referent.metadata["lccn"], "LCCN was not nil before resolving by ISSN.")

    # Handle the service
    VCR.use_cassette("russkaia pochta with no title by issn") do
      @primo_service.handle(request)
    end

    # Get latest from the DB after handling the service.
    request.referent.referent_values.reset
    request.dispatched_services.reset
    request.service_responses.reset

    # Test that the referent was enhanced
    assert_equal("russkai͡a pochta.", request.referent.title, "Title (normalized) was not enhances when resolveing by ISSN.")
    assert_equal("Russkai͡a pochta.", request.referent.metadata["jtitle"], "Journal title was not enhanced when resolving by ISSN.")
    assert_equal("Belgrad", request.referent.metadata["place"], "Publication place was not enhanced when resolving by ISSN.")
    assert_equal("Filološki fakultet, Katedra za slavistiku", request.referent.metadata["pub"], "Publisher was not enhanced when resolving by ISSN.")
    assert_equal("261559574", request.referent.metadata["oclcnum"], "OCLC number was not enhanced when resolving by ISSN.")
    assert_equal("2008262508", request.referent.metadata["lccn"], "LCCN was not enhanced when resolving by ISSN.")
  end
end
