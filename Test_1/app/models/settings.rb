#t.string "key",           :null => false
#t.string "type",          :null => false
#t.text   "value"
#t.text   "default_value", :null => false
class Settings < ActiveRecord::Base

end
