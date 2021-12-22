class DashboardController < ApplicationController
  def index
    unless current_user.api_key
      current_user.api_key = [*('A'..'Z'),*('0'..'9')].shuffle[0,32].join
      current_user.save
    end
  end

  def search
    q = params[:q].gsub(/[ \n]/, '')

    body = {}
    body[:size] = params[:size] || 150
    body[:from] = ((params[:page] || 1).to_i - 1) * body[:size]

    musts = []
    unless q.blank?
      q.split('|').each do |filter|
        field, value = filter.split('=')
        musts << {
          query_string: {
            query: value,
            fields: [field],
            # analyzer: 'keyword'
          }
        }
      end
    end

    unless current_user.is_admin?
      musts << {
        term: {
          user_id: current_user.id
        }
      }
      body[:_source] = {
        exclude: [ 'user_id', 'log_id' ]
      }
    end

    body[:query] = {
      bool: {
        must: musts
      }
    }
    body[:sort] = [{
      created_at: 'desc'
    }]
    p body
    results = begin
      $es_client.search index: 'logs', type: 'log', body: body
    rescue
    end
    return render json: {hits: [], count: 0} unless results
    hits = results['hits']['hits'].map do |x|
      result = x['_source']
      result['request'] = result['request'][0..100] + '...' if result['request'] && result['request'].size > 100
      result
    end

    render json: {hits: hits, count: results['hits']['total']['value']}
  end
end
