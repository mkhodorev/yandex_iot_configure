require 'yaml'
require 'yandex_iot_configure/config'

module YandexIotConfigure
  def self.apply_config(filename)
    yaml = YAML.load_file(filename)
    y = Config.new
    y.cookie = yaml['config']['cookie']
    y.x_csrf_token = yaml['config']['x_csrf_token']
    y.apply_schema(yaml['config']['schema'])
    y.apply_scenarios(yaml['config']['scenarios'])
  end
end
