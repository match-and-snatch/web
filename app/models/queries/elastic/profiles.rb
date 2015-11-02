module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      model 'User'

      body do |fulltext_query|
        query do
          function_score do
            query do
              dis_max do
                queries [
                  {match: {profile_name: fulltext_query}},
                  {match: {full_name: fulltext_query}},
                  {match: {profile_types_text: fulltext_query}}
                ]
              end
            end

            functions << { script_score: {script: '_score * log1p( doc["subscribers_count"].value )'}}
          end
        end
      end
    end
  end
end
