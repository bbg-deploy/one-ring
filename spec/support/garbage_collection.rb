module GarbageCollection
  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 1.0).to_f
  
  @@last_gc_run = Time.now
  @@reserved_ivars = %w(@loaded_fixtures @test_passed @fixture_cache @method_name @_assertion_wrapped @_result)

  def scrub_instance_variables
    (instance_variables - @@reserved_ivars).each do |ivar|
      instance_variable_set(ivar, nil)
    end
  end

  def begin_gc_deferment
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end
  
  def reconsider_gc_deferment
    if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable
  
      @@last_gc_run = Time.now
    end
  end
end