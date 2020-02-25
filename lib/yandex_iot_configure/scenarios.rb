module YandexIotConfigure
  class Scenarios
    SCENARIO_URI = 'https://iot.quasar.yandex.ru/m/user/scenarios'

    def initialize(cookie, x_csrf_token)
      @cookie = cookie
      @x_csrf_token = x_csrf_token
      update
    end

    def update
      read_scenarios
    end

    def all(update: false)
      self.update if update
      @scenarios || update
    end

    def scenarios(name, update: false)
      self.update if update
      all[name]
    end

    def delete_all
      update
      process = ProgressInfo.new(name: 'Delete scenarios', count: all.count)

      all.each do |_, scenarios|
        delete_by_id(scenarios['id'])
        process.update
      end

      update
      process.success
    end

    def delete(name)
      update
      id = scenarios(name)['id']
      delete_by_id(id)
    end

    def create(names, opts, icon = 'day', progress)
      update
      names = [names] unless names.is_a?(Array)

      names.each do |name|
        return "scenario '#{name}' exist" if all.key?(name)
      end

      devices_data = prepare_devices(opts)
      external_actions = prepare_yandex_station_actions(opts)

      names.each do |name|
        add_scenario(name, devices_data, external_actions, icon)
        progress.update
      end
    end

    private

    def prepare_devices(opts)
      return [] unless opts.key?(:devices)

      devices = []
      opts[:devices].each do |id, value|
        devices << {
          id: id,
          capabilities: [
            {
              type: 'devices.capabilities.on_off',
              state: { instance: 'on', value: value }
            }
          ]
        }
      end

      devices
    end

    def prepare_yandex_station_actions(opts)
      return [] unless opts.key?(:yandex_station_actions)

      external_actions = []
      opts[:yandex_station_actions].each do |text|
        external_actions << {
          type: 'scenario.external_action.text',
          parameters: {
            current_device: true,
            text: text
          }
        }
      end

      external_actions
    end

    def add_scenario(name, devices_data, external_actions, icon)
      response = Faraday.post(SCENARIO_URI) do |req|
        req.headers['Cookie'] = @cookie
        req.headers['x-csrf-token'] = @x_csrf_token
        req.headers['Content-Type'] = 'text/plain;charset=UTF-8'
        req.body = {
          name: name,
          icon: icon,
          trigger_type: 'scenario.trigger.voice',
          devices: devices_data,
          external_actions: external_actions
        }.to_json
      end
      puts "Add scenario #{name} error: #{response.body}" if response.status != 200
    end

    def read_scenarios
      response = Faraday.get(SCENARIO_URI) do |req|
        req.headers['Cookie'] = @cookie
      end

      if response.status != 200
        puts "Read scenarios error: #{response.body}"
        raise 'Read scenarios error'
      end

      @scenarios = {}

      JSON.parse(response.body)['scenarios'].each do |scenario|
        @scenarios[scenario['name']] = scenario
      end

      @scenarios
    end

    def delete_by_id(id)
      response = Faraday.delete("#{SCENARIO_URI}/#{id}") do |req|
        req.headers['Cookie'] = @cookie
        req.headers['x-csrf-token'] = @x_csrf_token
      end
      puts "Delete scenario #{id} error: #{response.body}" if response.status != 200
    end
  end
end
