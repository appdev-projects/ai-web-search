class ReportsController < ApplicationController
  def index
    matching_reports = Report.all

    @list_of_reports = matching_reports.order({ :date => :desc })

    render({ :template => "report_templates/index" })
  end

  def create
    chat = AI::Chat.new
    chat.model = "gpt-4o-mini"
    chat.web_search = true
    chat.schema = {
      "name": "response",
      "schema": {
        "type": "object",
        "properties": {
          "reports": {
            "type": "array",
            "description": "",
            "items": {
              "type": "object",
              "properties": {
                "title": {
                  "type": "string",
                  "description": "TItle of the article"
                },
                "summary": {
                  "type": "string",
                  "description": "Summary of the article"
                },
                "date": {
                  "type": "string",
                  "description": "date the article was published"
                },
                "url": {
                  "type": "string",
                  "description": "url where the article is located"
                }
              },
              "required": [
                "title",
                "summary",
                "date",
                "url"
              ],
              "additionalProperties": false
            }
          }
        },
        "required": [
          "reports"
        ],
        "additionalProperties": false
      },
      "strict": true
    }

    prompt = params.fetch("query_prompt")
    chat.system(prompt)

    response = chat.generate!
    report_array = response.fetch(:reports)

    report_array.each do |report_hash|
      the_report = Report.new
      the_report.title = report_hash.fetch(:title)
      the_report.summary = report_hash.fetch(:summary)
      the_report.date = report_hash.fetch(:date)
      the_report.url = report_hash.fetch(:url)
      the_report.save
    end

    redirect_to("/reports")
  end
end
