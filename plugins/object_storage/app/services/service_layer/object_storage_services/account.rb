# frozen_string_literal: true

module ServiceLayer
  module ObjectStorageServices
    # implements Swift storage object API
    module Account
      # ACCOUNT #

      ACCOUNT_ATTRMAP = {
        "x-account-container-count" => "container_count",
        "x-account-object-count" => "object_count",
        "x-account-meta-quota-bytes" => "bytes_quota",
        "x-container-meta-quota-count" => "object_count_quota",
        "x-account-bytes-used" => "bytes_used",
      }.freeze

      def account
        response =
          begin
            elektron_object_storage.head("/")
          rescue Elektron::Errors::ApiResponse => e
            # 200 success list containers
            # 202 success but no content found
            # 404 account is not existing
            return nil if e.code == 404
          end
        account_data =
          map_attribute_names(extract_header_data(response), ACCOUNT_ATTRMAP)
        ObjectStorage::Account.new(self, account_data)
      end
    end
  end
end
