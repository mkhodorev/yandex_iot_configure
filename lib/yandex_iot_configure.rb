require 'yaml'
require 'yandex_iot_configure/config'

module YandexIotConfigure
  def self.apply_config(filename)
    yaml = YAML.load_file(filename)
    y = Config.new
    y.cookie = yaml['config']['cookie']
    y.x_csrf_token = yaml['config']['x_csrf_token']
    y.apply_groups(yaml['config']['groups'])
    y.apply_scenarios(yaml['config']['scenarios'])
  end

  def self.load_file(filename)
    @@yaml = YAML.load_file(filename)
    @@y = Config.new
    @@y.cookie = @@yaml['config']['cookie']
    @@y.x_csrf_token = @@yaml['config']['x_csrf_token']
  end

  def self.delete_groups
    @@y.delete_groups
  end

  def self.delete_scenarios
    @@y.delete_scenarios
  end

  def self.delete_devices
    @@y.delete_devices
  end

  def self.apply_groups
    @@y.apply_groups(@@yaml['config']['groups'])
  end

  def self.apply_scenarios
    @@y.apply_scenarios(@@yaml['config']['scenarios'])
  end

  def self.print_groups
    @@y.print_group_names(@@yaml['config']['groups'])
  end

  def self.print_scenarios
    @@y.print_scenario_names(@@yaml['config']['scenarios'])
  end
end
