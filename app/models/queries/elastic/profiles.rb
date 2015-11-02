module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      scope do
        User.profile_owners.with_complete_profile.where(hidden: false)
          .where('users.subscribers_count > 0 OR users.profile_picture_url IS NOT NULL')
      end

      body do |fulltext_query|
        query do
          filtered do
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

            filter do
              term visible: true
            end
          end
        end
      end
    end
  end
end
