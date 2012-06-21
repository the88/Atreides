class Atreides::Configuration
  attr_accessor :user_model
  attr_accessor :admin_route_prefix
  attr_accessor :admin_route_redirect

  @@overrides ||= {}
  @@overriden_from ||= {}

  # Configuration defaults
  def initialize
    @user_model           = 'User'
    @admin_route_prefix   = 'admin'
    @admin_route_redirect = "/#{@admin_route_prefix}/pages"
  end

  def overrides
    @@overrides
  end

  def override *args
    from = caller[0]
    overrides = args.extract_options!
    args.each { |arg| overrides[arg] = arg.to_sym }
    overrides.each do | atreides_classname, host_concern_name |
      unless atreides_classname.to_s.starts_with? 'Atreides::'
        atreides_classname = "Atreides::#{atreides_classname}"
      end
      @@overrides[atreides_classname.to_sym] = [] if @@overrides[atreides_classname.to_sym].nil?
      @@overrides[atreides_classname.to_sym] << host_concern_name
      @@overriden_from[atreides_classname.to_sym] = from
    end
  end

  def inject_overrides atreides_class
    # Rails.logger.debug { "Injecting overrides in class #{atreides_class.inspect} !" }

    modules = @@overrides[atreides_class.to_s.to_sym] || []

    modules.uniq.each do |hostapp_module_name|
      begin
        host_module = hostapp_module_name.to_s.constantize
        # puts "\t\tInjecting #{host_module} into #{atreides_class}"
        atreides_class.instance_eval {
          include host_module
        }
      rescue NameError => e
        from = @overriden_from[atreides_class.to_s.to_sym] rescue "---"
        puts <<-ERR
        Atreides configuration error !
        Following Atreides's configuration, here: #{from.inspect}

        Atreides's' '#{atreides_class.to_s}' class should be overriden by a class named #{hostapp_module_name.inspect}.

        This #{hostapp_module_name.inspect} class could not be loaded !

        ERR
        raise e
      end
    end
  end
end
