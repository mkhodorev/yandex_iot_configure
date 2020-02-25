module YandexIotConfigure
  class Groups
    GROUP_URI = 'https://iot.quasar.yandex.ru/m/user/groups'

    def initialize(cookie, x_csrf_token)
      @cookie = cookie
      @x_csrf_token = x_csrf_token
      update
    end

    def update
      read_groups
    end

    def all(update: false)
      self.update if update
      @groups || update
    end

    def group(name, update: false)
      self.update if update
      all[name]
    end

    def delete_all
      update
      process = ProgressInfo.new(name: 'Delete groups', count: all.count)

      all.each do |_, group|
        delete_by_id(group['id'])
        process.update
      end

      process.success
    end

    def delete(name)
      update
      id = group(name)['id']
      delete_by_id(id)
    end

    def create(name)
      update
      return "group '#{name}' exist" if all.key?(name)
      add_group(name)
    end

    def create_groups_if_need(groups)
      process = ProgressInfo.new(name: 'Create groups', count: groups.count + 1)

      update
      process.update
      count = 0

      groups.each do |name|
        unless all.key?(name)
          add_group(name)
          count += 1
        end
        process.update
      end
      update if count > 0

      process.success

      count
    end

    def names_to_ids(names)
      names.map do |name|
        group(name)['id']
      end
    end

    def name_to_id(name)
      group(name)['id']
    end

    private

    def add_group(name)
      response = Faraday.post(GROUP_URI) do |req|
        req.headers['Cookie'] = @cookie
        req.headers['x-csrf-token'] = @x_csrf_token
        req.headers['Content-Type'] = 'text/plain;charset=UTF-8'
        req.body = { name: name }.to_json
      end
      puts "Add group #{name} error: #{response.body}" if response.status != 200
    end

    def read_groups
      response = Faraday.get(GROUP_URI) do |req|
        req.headers['Cookie'] = @cookie
      end

      if response.status != 200
        puts "Read groups error: #{response.body}"
        raise 'Read groups error'
      end

      @groups = {}
      JSON.parse(response.body)['groups'].each do |group|
        @groups[group['name']] = group
      end

      @groups
    end

    def delete_by_id(id)
      response = Faraday.delete("#{GROUP_URI}/#{id}") do |req|
        req.headers['Cookie'] = @cookie
        req.headers['x-csrf-token'] = @x_csrf_token
      end
      puts "Delete group #{id} error: #{response.body}" if response.status != 200
    end
  end
end
