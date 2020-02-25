module YandexIotConfigure
  class Devices
    DEVICES_URI = 'https://iot.quasar.yandex.ru/m/user/devices'

    def initialize(cookie, x_csrf_token)
      @cookie = cookie
      @x_csrf_token = x_csrf_token
      update
    end

    def update
      read_rooms
      parse_devices
    end

    def all(update: false)
      self.update if update
      @devices || update
    end

    def device(name, update: false)
      self.update if update
      all[name]
    end

    def add_device_to_groups(device_name, groups)
      id = device(device_name)['id']

      response = Faraday.put("#{DEVICES_URI}/#{id}/groups") do |req|
        req.headers['Cookie'] = @cookie
        req.headers['x-csrf-token'] = @x_csrf_token
        req.body = { groups: groups }.to_json
      end
      puts "Add group #{name} error: #{response.body}" if response.status != 200
    end

    def names_to_ids(names)
      names.map do |name|
        device(name)['id']
      end
    end

    def name_to_id(name)
      device(name)['id']
    end

    private

    def read_rooms
      response = Faraday.get(DEVICES_URI) do |req|
        req.headers['Cookie'] = @cookie
      end

      if response.status != 200
        puts "Read rooms error: #{response.body}"
        raise 'Read rooms error'
      end

      @rooms = JSON.parse(response.body)['rooms']
    end

    def parse_devices
      @devices = {}

      @rooms.each do |room|
        room_hash = { room['id'] => room['name'] }
        room['devices'].each do |device|
          @devices[device['name']] = device.merge(room_hash)
        end
      end

      @devices
    end
  end
end
