# frozen_string_literal: true

require "lograge/formatters/key_value"

class LogentriesFormatter < Lograge::Formatters::KeyValue
  def call(data)
    data[:path] = strip_query_string(data[:path])

    params = data.delete(:params).except("controller", "action", "format")
    data = data.merge(flatten_params(params, "params."))

    ga = data.delete(:ga) || {}
    data = data.merge(flatten_params(ga, "ga."))

    super
  end

  def parse_value(_key, value)
    return Kernel.format("%.2f", value) if value.is_a?(Float)

    value = "" if value.nil?
    value = value.to_s if value.is_a?(Symbol)
    value.inspect
  end

  def strip_query_string(path)
    index = path.index("?")
    index ? path[0, index] : path
  end

  def flatten_params(hash, prefix = "")
    hash.each_with_object({}) do |(key, value), ret|
      parse_param_value(value, ret, "#{prefix}#{key}")
    end
  end

  def parse_param_value(value, ret, prefixed_key)
    if value.is_a?(Hash)
      ret.merge!(flatten_params(value, "#{prefixed_key}."))
    elsif value.is_a?(Array)
      value.each_with_index do |inner_value, index|
        parse_param_value(inner_value, ret, "#{prefixed_key}.#{index}")
      end
    elsif value.present?
      ret[prefixed_key] = value
    end
  end
end
