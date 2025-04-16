# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def campus
    collection? ? first('campus_unit_ssm') : collection.first('campus_unit_ssm')
  end

  def parent_campus
    fetch('parent_campus_unit_ssm', [])
  end

  def containers
    fetch('containers_ssim', [])
  end

  def normalized_title_html
    self['normalized_title_html_ssm']&.first
  end
end
