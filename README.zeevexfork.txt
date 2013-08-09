
Changes from original version:

* has_easy now accepts an ":autosave => TRUTHYVAL" parameter to force autosaving on
  a has_easy association.
  
* has_easy now accepts an ":accessible => TRUTHYVAL" parameter to make a parameter of
  the form PREFGROUP_PREFNAME accessible via bulk assignment.  
  
* the Configurator object (used inside a has_easy block) now has a "define_boolean"
  method which defines a boolean in a form-friendly way.  By default it uses '1' and
  '0' as the true and false values, respectively, but the define_boolean method will
  accept :true => TRUEVALUE and :false => FALSEVALUE options.
  

Example of the new options, showing three defined preference flags which will act
identically.
  
  has_easy :myprefs, :autosave => true, :accessible => true do |myprefs|
    myprefs.define_boolean :flag1

    myprefs.define_boolean :flag2, :true => '1', :false => '0'


    myprefs.define :flag3,  :type_check => [TrueClass, FalseClass],
                :preprocess => Proc.new{ |value| value == '1' },
                :postprocess => Proc.new{ |value| value ? '1' : '0' }
  end
  
  # this is redundant because of the :accessible => true call above
  
  attr_accessible :myprefs_flag1, :myprefs_flag2, :myprefs_flag3
  
TODO:

- check out this fork for rails3 fixes: https://github.com/jwigal/has_easy/commits/master
