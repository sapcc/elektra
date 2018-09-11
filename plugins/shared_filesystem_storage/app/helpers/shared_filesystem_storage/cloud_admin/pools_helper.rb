# frozen_string_literal: true

module SharedFilesystemStorage
  module CloudAdmin
    module PoolsHelper
      def format_percentage(absolute_value, percentage_value)
        content_tag(:span, title: "#{percentage_value}%") { absolute_value }
      end

      def accumulated_pools(pools)
        pools.each_with_object({}) do |pool, map|
          reserved_capacity_float = (pool.capabilities['reserved_percentage'] * pool.capabilities['total_capacity_gb']) / 100

          map[pool.availability_zone] ||= {
            availability_zone: pool.availability_zone,
            total_capacity: 0,
            allocated_capacity: 0,
            # allocated_capacity_percentage: 0.0,
            free_capacity: 0,
            # free_capacity_percentage: 0.0,
            reserved_capacity: 0.0,
            # reserved_capacity_percentage: 0.0,
            items: []
          }

          map[pool.availability_zone][:total_capacity] += pool.capabilities['total_capacity_gb']
          map[pool.availability_zone][:allocated_capacity] += pool.capabilities['allocated_capacity_gb']
          # map[pool.availability_zone][:allocated_capacity_percentage] += (pool.capabilities['allocated_capacity_gb'] / pool.capabilities['total_capacity_gb'] * 100).round(2)
          map[pool.availability_zone][:free_capacity] += pool.capabilities['free_capacity_gb'] - reserved_capacity_float
          # map[pool.availability_zone][:free_capacity_percentage] += ((pool.capabilities['free_capacity_gb'] / pool.capabilities['total_capacity_gb'] * 100) - reserved_capacity_percentage).round(2)
          map[pool.availability_zone][:reserved_capacity] += reserved_capacity_float
          # map[pool.availability_zone][:reserved_capacity_percentage] += pool.capabilities['reserved_percentage']

          map[pool.availability_zone][:items] << pool
        end.values.sort_by! { |data| data[:availability_zone] }.each do |data|
          data[:allocated_capacity_percentage] = (data[:allocated_capacity] / data[:total_capacity] * 100).round(2)
          data[:free_capacity_percentage] = (data[:free_capacity] / data[:total_capacity] * 100).round(2)
          data[:reserved_capacity_percentage] = (data[:reserved_capacity] / data[:total_capacity] * 100).round(2)

          data[:total_capacity] = Core::DataType.new(:bytes, :giga).format(data[:total_capacity])
          data[:allocated_capacity] = Core::DataType.new(:bytes, :giga).format(data[:allocated_capacity])
          data[:free_capacity] = Core::DataType.new(:bytes, :giga).format(data[:free_capacity])
          data[:reserved_capacity] = Core::DataType.new(:bytes, :giga).format(data[:reserved_capacity])
        end
      end
    end
  end
end
