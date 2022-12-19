# frozen_string_literal: true

module Reports
  class CostController < DashboardController
    authorization_context "reports"
    authorization_required

    before_action :role_assigments, only: %i[users groups]

    def project
      # data = '['\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"compute","measure":"ram","allocation_type":"quota","amount":7429.99348,"amount_unit":"GiBh","duration":742.99348,"duration_unit":"h","price_loc":20.12878,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"instance","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":5.92056,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"block_storage","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":2.5,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"shared_file_storage","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":3.567,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"router","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":37.89,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"loadbalancer","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":1.23,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":5,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"licenses","measure":"os_windows","allocation_type":"usage","amount":170.27098,"amount_unit":"pieceh","duration":170.27098,"duration_unit":"h","price_loc":0.123,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":6,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"compute","measure":"ram","allocation_type":"quota","amount":2699.99763,"amount_unit":"GiBh","duration":269.99763,"duration_unit":"h","price_loc":7.31463,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":6,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"instance","measure":"os_windows","allocation_type":"usage","amount":93.00059,"amount_unit":"pieceh","duration":93.00059,"duration_unit":"h","price_loc":3.23379,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":6,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"router","measure":"os_windows","allocation_type":"usage","amount":93.00059,"amount_unit":"pieceh","duration":93.00059,"duration_unit":"h","price_loc":1.5,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false},'\
      #   '{"region":"eu-de-1","year":2018,"month":6,"project_id":"1d1ad583e98c4913a0226feac0f010f9","service":"block_storage","measure":"os_windows","allocation_type":"usage","amount":93.00059,"amount_unit":"pieceh","duration":93.00059,"duration_unit":"h","price_loc":3.9,"price_sec":0,"currency":"EUR","cost_object":"101050123","cost_object_type":"CC","co_inherited":false}'\
      # ']'

      if request.format.json?
        data = services.masterdata_cockpit.get_project_costing
      end

      respond_to do |format|
        format.html
        format.json { render json: data }
      end
    end

    def domain
      if request.format.json?
        data = services.masterdata_cockpit.get_domain_costing
      end

      respond_to do |format|
        format.html
        format.json { render json: data }
      end
    end
  end
end
