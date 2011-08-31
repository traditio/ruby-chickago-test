require "redis"




module DbSettingsExceptions

  class UnsupportedType < Exception
  end

  class AlreadyExists < Exception
  end

  class DoesNotExist < Exception
  end

  class KeyMustBeString < Exception
  end

  class IncorrectType < Exception
  end

end


class DbSettings

  #When you create settings with key and value, class stores info about value's type.
  #Later if you want to update value, it will check if new value has a correct type
  #and raises a error if not.

  ALLOWED_TYPES = %w(Boolean Fixnum Float String)
  DB_SETTINGS_KEY = "dbSettings" # key in redis

  def self.redis
    @@redis ||= Redis.new
  end

  #Create new setting
  def self.create(key, value)
    # TODO: проверить что вызываются observers

    if not ALLOWED_TYPES.include?(type_of(value))
      raise DbSettingsExceptions::UnsupportedType, "#{type_of(value)} is not supported"
    end

    raise_if_key_exists(key)
    packed = Marshal.dump value
    type = type_of(value)

    Settings.create :key => key, :value => packed, :value_type => type, :default_value => packed
    true
  end

  #Delete setting
  def self.delete(key)
    # TODO: проверить что вызываются observers
    Settings.destroy_all(:key => key)
    true
  end

  #Reset setting to default value
  def self.reset(key)
    # TODO: проверить что вызываются observers
    setting = get_model!(key)
    setting.value = setting.default_value
    setting.save
    true
  end

  #Update existing settings with new value
  def self.update(key, value)
    # TODO: проверить что вызываются observers
    setting = get_model!(key)
    if is_of_type?(value, setting.value_type)
      setting.value = Marshal.dump value
      setting.save
    else
      raise DbSettingsExceptions::IncorrectType, "Type of value #{value.inspect} must be #{setting.value_type}"
    end
  end

  #Get setting by key
  def self.get(key, from_cache=true)

    #TODO: в get реализовать логину выборки из редиса и базы.


    setting = Settings.where(:key => key).first

    unless setting.nil?
      begin
        value = Marshal.load(setting.value)
        #if value and was_nil_in_cache
        #  redis.hset DB_SETTINGS_KEY,  key, value
        #end
        #value
      rescue ArgumentError # invalid marshal data in database
        nil
      end
    end
  end

  #Get all settings
  def self.all(from_cache=true)
    if from_cache
    settings = redis.hgetall DB_SETTINGS_KEY
      was_nil_in_cache = (settings.nil? or settings.empty?)
    end
    if not from_cache or was_nil_in_cache
      puts "was nul in cache"
    settings = Settings.select(%w(key value))
    end

    if settings and was_nil_in_cache
      settings.collect do |s|
        redis.hset DB_SETTINGS_KEY, s.key, s.value
      end
    end

    settings.collect do |s|
      k, v = s.is_a?(Array) ? s : [s.key, s.value]
      begin
        {:key => k, :value => Marshal.load(v)}
      rescue ArgumentError # invalid marshal data in database
        {:key => k, :value => nil}
      end
    end
  end

  private

  #Is value of type specified by string?
  def self.is_of_type?(value, type)
    if type == 'Boolean'
      if (value.is_a?(TrueClass) || value.is_a?(FalseClass))
        true
      else
        false
      end
    else
      value.is_a? Kernel.const_get(type)
    end
  end

  #Return name of values's type
  def self.type_of(value)
    if (value.is_a?(TrueClass) || value.is_a?(FalseClass))
      'Boolean'
    else
      value.class.name
    end
  end

  def self.get_model!(key)
    setting = Settings.where(:key => key).first
    if setting.nil?
      raise DbSettingsExceptions::DoesNotExist, "#{key} does not exist"
    end
    setting
  end

  def self.raise_if_key_exists(key)
    if Settings.where(:key => key).exists?
      raise DbSettingsExceptions::AlreadyExists, "#{key} already exists"
    end
  end

end

