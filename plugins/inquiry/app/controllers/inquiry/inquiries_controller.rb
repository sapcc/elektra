module Inquiry
  class InquiriesController < DashboardController
    def index
      @inquiries = services.inquiry.inquiries(@scoped_project_id)
    end

    def new
      @inquiry = Inquiry.new(requester_id: current_user.id)
    end

    def show
      @inquiry = Inquiry.find(params[:id]) rescue nil
    end

    def create
      @inquiry = Inquiry.new()
      @inquiry.kind = inquiry_params[:kind]
      @inquiry.description = inquiry_params[:description]
      @inquiry.requester_id = current_user.id
      @inquiry.payload = {
          "run_provision_on_warehouse_push": false,
          "sap_openstack": {
              "compiletime": true
          },
          "openstack": {
              "release": "Kilo",
              "repo": {
                  "yum": {
                      "url": "https://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7/"
                  }
              },
              "admin_user": "monsooncc_admin",
              "db": {
                  "admin_user": "postgres",
                  "admin_password": "iloverandompasswordsbutthiswilldo"
              },
              "keystone": {
                  "host": "localhost",
                  "port": "5000",
                  "admin_port": "5000"
              },
              "glance": {
                  "db": {
                      "host": "localhost"
                  }
              },
              "ssl": {
                  "enable": false,
                  "certificate_content": "-----BEGIN CERTIFICATE-----\nMIIFpDCCA4ygAwIBAgICN1IwDQYJKoZIhvcNAQELBQAwRDELMAkGA1UEBhMCREUx\nETAPBgNVBAcMCFdhbGxkb3JmMQwwCgYDVQQKDANTQVAxFDASBgNVBAMMC1NBUE5l\ndENBX0cyMB4XDTE1MDYwNTEyMzUzM1oXDTE3MDYwNTEyMzUzM1owgZ0xCzAJBgNV\nBAYTAkRFMREwDwYDVQQHEwhXYWxsZG9yZjEMMAoGA1UEChMDU0FQMS0wKwYDVQQL\nEyRTQVAgQ0xNIENNIEluZnJhc3RydWN0dXJlIEF1dG9tYXRpb24xITAfBgNVBAMM\nGCouZXUtZGUtMS5jYy5tby5zYXAuY29ycDEbMBkGA1UECBMSQmFkZW4tV3VlcnR0\nZW1iZXJnMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgMcGC8rNsV9Of5qef\nMS0Om5Cwj0ghEsjyBxCOzoFhhufCH3UqMD8yiWmUCRDZxSm3spqX3qLVLr1LslKs\n+8YA5z4eKxg6s5bgmMKraQfRFw8V+eswjGRHd7gSRZuO4ESIq9m5wVKjs9HZIbsO\nm709vtfHwAdJX+/+3ab9nCG0jwIDAQABo4IByDCCAcQwHQYDVR0lBBYwFAYIKwYB\nBQUHAwEGCCsGAQUFBwMCMB8GA1UdIwQYMBaAFDgkr411Evw4PzeDEK+QPPwbIVr/\nMEkGCCsGAQUFBwEBBD0wOzA5BggrBgEFBQcwAoYtaHR0cDovL2FpYS5wa2kuY28u\nc2FwLmNvbS9haWEvU0FQTmV0Q0FfRzIuY3J0MIHfBgNVHR8EgdcwgdQwgdGggc6g\ngcuGLWh0dHA6Ly9jZHAucGtpLmNvLnNhcC5jb20vY2RwL1NBUE5ldENBX0cyLmNy\nbIaBmWxkYXA6Ly8vQ049U0FQTkVUQ0FHMiwgQ049U0FQTkVUQ0FHMiwgQ049Q0RQ\nLCBDTj1QdWJsaWMgS2V5IFNlcnZpY2VzLCBDTj1TZXJ2aWNlcywgQ049Q29uZmln\ndXJhdGlvbiwgREM9Z2xvYmFsLCBEQz1jb3JwLCBEQz1zYXA/Y2VydGlmaWNhdGVy\nZXZvY2F0aW9ubGlzdDARBgNVHQ4ECgQISgv5+5aTEzcwDgYDVR0PAQH/BAQDAgWg\nMCQGA1UdEQQdMBuBGUkwMDk3MTNAZXhjaGFuZ2Uuc2FwLmNvcnAwDAYDVR0TAQH/\nBAIwADANBgkqhkiG9w0BAQsFAAOCAgEAhYOJDUq22pGILDcrmdYKDLeL2ez7VLl0\nACnTHSmesZeQOt4V7Se7KS2kH/skrIIzjfMQFdeN8PZ3gCZKaG05/qlzDQQLE4Ny\ntyj0/Qx2MDmljHdHVdqV00RRvWFsERN2IJoNCbvCfeImmr/fi5s8NOypSYhULukO\nHXo8fDi+03IwAdckGaY5nDtLMQLxbmAj/5iat3BvRVcPZZdj7C1xmLz/OSkrqhgl\nl2K64E6865tUEMiAZJQ9NxGmajjlufvK7g7AWyK3XZHDQfGoituBxJX803Va3rcm\n5v5t06/mA61giJAdKf7yChjD46yNRIBOLR9MVUN9nfK+o9/a9Du6dvrmMPIlF73W\n4wpbdGgW4qJmRh5S1frPGprpNGXEQc/cSVgdH74oBz3SMBDocXX0VGh686hU5cQs\nOyjMKq6koX3qZtW44zY/VEM9ZrNFTpi56isJ5rVsdWNMyLKSYrNxORq7atX1e4xh\nfVBs8pDGz/wNb9REPMroYivQtOKMFx0CODK8AyHifh7JSUkRiQJ7mTmPpLBM710Y\nNvpB1+fnjmvHZNKTsiYPDzO0TZMJLTwQOUbb9Qp8Ba/sIy/yhRF9SvxNyMWjbwB/\nzBHYVOkmOC/urvD3FETEn0Gup54e3IyprIVA/6VQmSeKLFYq96+hfk35myNpfHGR\nwRRFAXbeJbQ=\n-----END CERTIFICATE-----",
                  "key_content": "-----BEGIN RSA PRIVATE KEY-----\n***REMOVED***3Uq\nMD8yiWmUCRDZxSm3spqX3qLVLr1LslKs+8YA5z4eKxg6s5bgmMKraQfRFw8V+esw\njGRHd7gSRZuO4ESIq9m5wVKjs9HZIbsOm709vtfHwAdJX+/+3ab9nCG0jwIDAQAB\nAoGAAt3gAZKk5K/CzvqeDhUM5HDsyrUqUPHyi9W3Snwtf1fAQuUwFFgFltnW9cOf\n6Yjx3Z11CJgaMOumE/+1uuyFPZuWhp6YtkBPquiJA+5OUOOkewfGggcz9AnG2ZnT\n/gvr14w3u+xNZZ0EJKIAZt9NsyMQLRzPYj503FkoL2YwPZECQQD0+W9wUx7kr6Qz\npdf0gHvSUSt+ml5RTQF4mA36MV4qMrvW387K9oCg9f4pd8z90YezYAggMESZjWKH\nzj5Rw887AkEA6kjlX/A6p9NP4mLyNiIoEZy3sTkNlYV7O/Oa/8cY6NCWb8XxD54m\nAJqWfvkPm01VRvFHkj8siY+Txrb5OCXCvQJAQIz9nVZ5vH6/wNBBgG7escOrt1eL\n5NZqvdErVbLugiYOMweUYQzlRgSr7VdhD7zHii+S1JCDcwa7YNequjbjgwJAY/W6\nOBbNT/Gu8c55vXMRWYJeNbU8AIG1NL0ZcuxFyn/Ez+fKlHlLiZJrh71IVWDHc79a\nZCGkJQUnbe9/od8qmQJASxktdcWr1379aWqC+0fbuJGMV6fgqgYJIN2Rz0Im36+6\nXIdMuMNvBpoOFGamERD//7HS3Q3EXSEgLmx0qwYBlA==\n-----END RSA PRIVATE KEY-----",
                  "chain_content": "-----BEGIN CERTIFICATE-----\n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\n7HJNBB1ZTjnrxJAgCQgNBIQ=\n-----END CERTIFICATE-----"
              }
          }
      }

      if @inquiry.save
        flash[:notice] = "Inquiry successfully created."
        redirect_to inquiries_path
      else
        render action: :new
      end
    end

    def edit
      @inquiry = Inquiry.find(params[:id]) rescue nil
    end

    def update
      @inquiry = Inquiry.find(params[:id]) rescue nil
      if @inquiry.aasm_state != inquiry_params[:aasm_state]
        @inquiry.process_step_description = inquiry_params[:process_step_description]
        if @inquiry.valid?
          @inquiry.reject!({user_id: current_user.id, description: inquiry_params[:process_step_description]}) if inquiry_params[:aasm_state] == "rejected"
          @inquiry.approve!({user_id: current_user.id, description: inquiry_params[:process_step_description]}) if inquiry_params[:aasm_state] == "approved"
          @inquiry.reopen!({user_id: current_user.id, description: inquiry_params[:process_step_description]}) if inquiry_params[:aasm_state] == "open"
          flash[:notice] = "Network successfully updated."
          redirect_to inquiries_path
        else
          #@inquiry.aasm_state = inquiry_params[:aasm_state]
          render action: :edit
        end
      else
        @inquiry.errors.messages[:aasm_state] =  ["Please change status before saving"]
        render action: :edit
      end
    end

    def destroy
      @inquiry = Inquiry.find(params[:id]) rescue nil

      if @inquiry
        if @inquiry.destroy
          flash[:notice] = "Inquiry successfully deleted."
        else
          flash[:error] = @inquiry.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
        end
      end

      respond_to do |format|
        format.js {}
        format.html { redirect_to inquiries_path }
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:kind, :description, :aasm_state, :process_step_description)
    end
  end
end
