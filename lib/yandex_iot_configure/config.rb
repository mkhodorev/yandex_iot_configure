require 'faraday'
require 'json'
require 'yandex_iot_configure/devices'
require 'yandex_iot_configure/groups'
require 'yandex_iot_configure/scenarios'
require 'yandex_iot_configure/phrase'
require 'yandex_iot_configure/progress_info'

module YandexIotConfigure
  class Config
    attr_writer :cookie, :x_csrf_token

    def initialize(cookie: '', x_csrf_token: '')
      @cookie = cookie
      @x_csrf_token = x_csrf_token
    end

    def devices
      return 'set cookie' if @cookie.empty?
      return 'set x-csrf-token' if @x_csrf_token.empty?
      @devices ||= Devices.new(@cookie, @x_csrf_token)
    end

    def groups
      return 'set cookie' if @cookie.empty?
      return 'set x-csrf-token' if @x_csrf_token.empty?
      @groups ||= Groups.new(@cookie, @x_csrf_token)
    end

    def scenarios
      return 'set cookie' if @cookie.empty?
      return 'set x-csrf-token' if @x_csrf_token.empty?
      @scenarios ||= Scenarios.new(@cookie, @x_csrf_token)
    end

    def apply_schema(data)
      return if data.nil?
      group_names = []
      data.each do |name, group|
        g = Phrase.compile(group)
        data[name] = g
        group_names += g
      end
      group_names.uniq!

      if group_names.count > 1000
        puts "Yandex allow max 1000 groups. Config contains #{group_names.count}"
        return
      else
        puts "Find #{scenario_names_count} groups"
      end
      validate_device_names(data.keys, 'schema')

      groups.delete_all
      groups.create_groups_if_need(group_names)

      process = ProgressInfo.new(name: 'Apply schema', count: data.count)
      data.each do |name, group_data|
        ids = groups.names_to_ids(group_data)
        devices.add_device_to_groups(name, ids)
        process.update
      end
      process.success
    rescue
      puts "\nApply schema error"
    end

    def apply_scenarios(data)
      return if data.nil?
      expand_scenario_names(data)

      scenario_names_count = scenario_names(data).count
      if scenario_names_count > 1000
        puts "Yandex allow max 1000 scenarios. Config contains #{scenario_names_count}"
        return
      else
        puts "Find #{scenario_names_count} scenarios"
      end

      validate_scenarios(data)
      scenarios.delete_all
      process = ProgressInfo.new(name: 'Apply scenarios', count: scenario_names_count)

      data.each do |scenario|
        names = scenario['name']
        icon = scenario['icon'] || 'day'

        opts = {
          devices: {},
          yandex_station_actions: []
        }

        scenario['actions'].each do |device_name, value|
          if device_name.downcase == 'алиса' || device_name.downcase == 'yandex_station'
            opts[:yandex_station_actions] << value
          else
            device_id = devices.name_to_id(device_name)
            opts[:devices][device_id] = value
          end
        end

        scenarios.create(names, opts, icon, process)
      end

      process.success
    rescue
      puts "\nApply scenarios error"
    end

    private

    def expand_scenario_names(data)
      data.each do |scenario|
        if scenario['name'].is_a?(String)
          scenario['name'] = [scenario['name']]
        elsif scenario['name'].is_a?(Array) || scenario['name'].is_a?(Hash)
          scenario['name'] = Phrase.compile(scenario['name'])
        end
      end
    end

    def scenario_names(data)
      result = []
      data.each do |scenario|
        if scenario['name'].is_a?(String)
          result << name
        elsif scenario['name'].is_a?(Array)
          result += scenario['name']
        end
      end
      result
    end

    def device_names(data)
      result = []
      data.each do |scenario|
        result += scenario['actions'].keys.select { |s| s.downcase != 'алиса' && s.downcase != 'yandex_station' }
      end
      result
    end

    def validate_scenarios(data)
      validate_device_names(device_names(data), 'scenarios')
      check_uniq_array(scenario_names(data), 'schema')
    end

    def check_uniq_array(data, item_name)
      result = data - data.uniq
      unless result.empty?
        puts "#{item_name} not uniq:"
        result.each do |name|
          puts "  #{name}"
        end
        raise
      end
    end

    def validate_device_names(device_names, item_name)
      exists_device_list = exists_devices(device_names.uniq)
      unless exists_device_list.empty?
        print_exists_device_list(exists_device_list, item_name)
        raise
      end
    end

    def print_exists_device_list(data, item_name)
      puts "device from #{item_name} not exist in Yandex Smart Home:"
      data.each do |name|
        puts "  #{name}"
      end
    end

    def exists_devices(data)
      result = []
      data.each do |name|
        result << name unless devices.all.key?(name)
      end
      result
    end
  end
end
