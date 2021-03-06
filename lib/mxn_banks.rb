# frozen_string_literal: true

require 'mxn_banks/version'

module MxnBanks
  autoload :Bank, 'mxn_banks/bank'

  def self.from_iban(num)
    a = to_hash.select { |b| b[:number] == num.slice(0, 3) }
    fail ArgumentError, 'Invalid bank code' if a.empty?
    Bank.new(a.first)
  end

  def self.to_hash
    json_file = File.read(File.join(File.dirname(__FILE__), 'banks.json'))
    @banks ||= JSON.parse(json_file, symbolize_names: true)
  end

  def self.valid?(clabe)
    return false if clabe.length < 18
    sliced_clabe = clabe.slice(0, 17).split('')
    w_factor = weight(sliced_clabe)
    module_ten = sliced_clabe.map.with_index { |n, i| (n.to_i * w_factor[i]).modulo(10) }
    clabe.slice(-1).to_i == current_control_digit(module_ten)
  end

  def self.weight(clabe)
    w_factor = { 0 => 3, 1 => 7, 2 => 1 }
    clabe.map.with_index { |_n, i| w_factor[i.to_i.modulo(3)] }
  end

  def self.current_control_digit(arr)
    module_sum = arr.reduce { |a, e| a + e }
    (10 - module_sum.modulo(10)).modulo(10)
  end
end
