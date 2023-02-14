# frozen_string_literal: true

module Lbaas2
  class L7policy < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :action, presence: true

    def attributes_for_create
      {
        "name" => read("name"),
        "description" => read("description"),
        "position" => read("position"),
        "action" => read("action"),
        "redirect_url" => read("redirect_url"),
        "redirect_prefix" => read("redirect_prefix"),
        "redirect_http_code" => read("redirect_http_code"),
        "redirect_pool_id" => read("redirect_pool_id"),
        "tags" => read("tags"),
        "listener_id" => read("listener_id"),
        "project_id" => read("project_id"),
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        "name" => read("name"),
        "description" => read("description"),
        "position" => read("position"),
        "action" => read("action"),
        "redirect_url" => read("redirect_url"),
        "redirect_prefix" => read("redirect_prefix"),
        "redirect_http_code" => read("redirect_http_code"),
        "redirect_pool_id" => read("redirect_pool_id"),
        "tags" => read("tags"),
      }
    end
  end
end
