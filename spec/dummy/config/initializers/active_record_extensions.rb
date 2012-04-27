require 'digest/md5'

module ActiveRecord

  #XXX class XmlSerializer < ActiveRecord::Serialization::Serializer
  #XXX   def add_procs
  #XXX     if procs = options.delete(:procs)
  #XXX       [ *procs ].each do |proc|
  #XXX         proc.call(*(proc.arity > 1 ? [options, @record] : [options]))
  #XXX       end
  #XXX     end
  #XXX   end
  #XXX end
end
