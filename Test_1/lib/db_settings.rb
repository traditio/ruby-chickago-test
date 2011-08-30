class DbSettings

  ALLOWED_TYPES = %w(Boolean Fixnum Float String)

  def self.create key, value
    # TODO: впихнуть проверку что валуе вр азешенных типах
    #TODO: превращать в строку например в json
    # TODO: проверять разрешенные типы
    # TODO: проверить что вызываются observers
    if Settings.where(:key => key).exists?
      raise "Already exists"
    end
    type = value_type(value)
    Settings.create :key => key, :value => value, :value_type => type, :default_value => value
    true
  end

  def self.delete key
    # TODO: проверить что вызываются observers
    Settings.destroy_all(:key => key)
    true
  end

  def self.reset key
    # TODO: выбрасывать исключение если нет этго ключа
    # TODO: проверить что вызываются observers
    settings = Settings.where(:key => key).first
    settings.value = settings.default_value
    settings.save
    true
  end

  def self.update key, value

    # TODO: проверить что вызываются observers
    s = Settings.where(:key => key).first
    # TODO: выбрасывать исключение если нет этго ключа
    if value_has_right_type?(value, s.value_type)
      s.value = value
      s.save
    else
      raise ArgumentError, "Type of value #{value.inspect} must be #{s.value_type}"
    end
  end

  def self.get key
    #TODO: восстанавливать  оригинальный ип
    s = Settings.where(:key => key).first
    {:key => s.key, :value => s.value} unless s.nil?
  end

  def self.all
    Settings.select(%w(key value)).collect { |s| {:key => s.key, :value => s.value} }
  end

  private

  def self.value_has_right_type? value, type
    if type == 'boolean' and (value.is_a?(TrueClass) || value.is_a?(FalseClass))
      true
    else
      value.is_a? Kernel.const_get(type)
    end
  end

  def self.value_type value
    if (value.is_a?(TrueClass) || value.is_a?(FalseClass))
      'Boolean'
    else
      value.class.name
    end
  end

end

