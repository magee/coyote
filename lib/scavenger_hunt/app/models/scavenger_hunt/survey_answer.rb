class ScavengerHunt::SurveyAnswer < ScavengerHunt::ApplicationRecord
  belongs_to :player
  belongs_to :survey_question
end
