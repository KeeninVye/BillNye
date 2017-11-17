require_relative 'bill-nye/version'
require_relative 'bill-nye/bnlogger'
require_relative 'bill-nye/debit'
require_relative 'bill-nye/credit'
require 'date'
require 'csv'
require 'time'

module BillNye

  class BillNye

    def initialize()
    	@REGEX_PURCHASE = / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Card Purchase[a-zA-Z ]+)(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+ )(?<amount>[-,0-9]+\.[0-9]{2}) +(?<balance>[-,0-9]+\.[0-9]{2})/
    	@REX_TRANSFER 	= / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>[a-zA-Z .0-9#:]+ ) +(?<amount>[-,0-9]+\.[0-9]{2}) +(?<balance>[-,0-9,]+\.[0-9]{2})/
		@REX_PUR_RECUR 	= / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Recurring Card Purchase) (?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+ ) *(?<amount>[-,0-9]+\.[0-9]{2}) +(?<balance>[-,0-9]+\.[0-9]{2})/
		@REX_PUR_RETURN = / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Purchase Return) +(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+ )  (?<amount>[-,0-9]*\.[0-9]{2}) +(?<balance>[-,0-9]+\.[0-9]{2})/
		@REX_ATM_WITH 	= / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Non-Chase ATM Withdraw) +(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+ )(?<amount>[-,0-9]+\.[0-9]{2}) +(?<balance>[-,0-9]+\.[0-9]{2})/
		@REX_ATM_FEE 	= / *(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>.*Fee.*) +(?<amount>[-,0-9]*.[0-9]{2}) +(?<balance>[-,0-9]*\.[0-9]{2})/
		@REX_CREDIT 	= / *(?<process_date>[0-9]{2}\/[0-9]{2}) + (?<source>.+ )(?<amount>[-,0-9]+\.[0-9]{2})/
		@REX_SAVINGS 	= / +SAVINGS SUMMARY/

		@log 			= BNLogger.log
    end

  	def parse_pdfs(dir, type)
  		_xaction_list = []
  		Dir.foreach(dir) do |pdf|
  			begin
  				_xactions = parse_pdf("#{dir}#{pdf}", type)
  				_xaction_list << _xactions
  			rescue
  				p "Failed to convert #{pdf} to text."
  			end
  		end
  		return _xaction_list
  	end

  	def parse_pdf(pdf, type)
  		_xactions = []
		begin
			`pdftotext -layout #{pdf}`
			_match 		= /(?<filename>.+).pdf/.match(pdf)
			txt 		= "#{_match[:filename]}.txt"
		rescue => e
			p "Error #{e}: Failed to convert #{pdf} to text."
		end
		
		File.open("#{txt}", "r") do |file_handle|
			file_handle.each_line do |line|
				case type
				when 1
					_xaction = parse_debit(line)
				when 2
					_xaction = parse_credit(line)
				end

				if !_xaction.nil?
					_xactions << _xaction
				end
			end
		end

		return _xactions
  	end

	def parse_credit(line)
		_credit = nil
		if !@REX_CREDIT.match(line).nil?
			_match 	= @REX_CREDIT.match(line)
			_credit = credit_default(_match)
			@log.info{ "Match CREDIT: #{_credit}" }
		end
		return _credit
	end

	def credit_default(match)
		processDate = match[:process_date].strip
		type 		= "Credit"
		source 		= match[:source].strip
		amount 		= match[:amount].gsub(/[\s,]/ ,"")
		return Credit.new(processDate, type, source, amount)
	end

  	def parse_debit(line)
  		_debit = nil
  		begin
	  		if !@REGEX_PURCHASE.match(line).nil?
	  			_match 	= @REGEX_PURCHASE.match(line)
	  			_debit = debit_default(_match)
		  		@log.info{ "Match PURCHASE: #{_debit}" }
	 		elsif !@REX_PUR_RECUR.match(line).nil?
	  			_match	= @REX_PUR_RECUR.match(line)
	  			_debit = debit_default(_match)
		  		@log.info{ "Match PURCHASE RECURRING: #{_debit}" }
	  		elsif !@REX_PUR_RETURN.match(line).nil?
	  			_match	= @REX_PUR_RETURN.match(line)
	  			_debit = debit_default(_match)
		  		@log.info{ "Match PURCHASE RETURN: #{_debit}" }
	  		elsif !@REX_ATM_WITH.match(line).nil?
	  			_match	= @REX_ATM_WITH.match(line)
	  			_debit = debit_atm_with(_match)
		  		@log.info{ "Match ATM WITH: #{_debit}" }
	  		elsif !@REX_ATM_FEE.match(line).nil?
	  			_match	= @REX_ATM_FEE.match(line)
	  			_debit = debit_transfer_or_fee(_match)
		  		@log.info{ "ATM FEE: #{_debit}" }
	  		elsif !@REX_TRANSFER.match(line).nil?
	  			_match	= @REX_TRANSFER.match(line)
	   			_debit = debit_transfer_or_fee(_match)
		  		@log.info{ "Match TRANSFER: #{_debit}" }
		  	else
		  		@log.error{ "NO-MATCH on: #{_debit}" }
	  		end
	  	rescue => e
	  		@log.error{"Error #{e} on: #{_debit}"}
	  	end
	  	return _debit
  	end

	def debit_default(match)
		processDate = match[:process_date].strip
		source 		= match[:source].strip
		amount 		= match[:amount].gsub(/[\s,]/ ,"")
		type 		= match[:type].strip
		usageDate	= match[:usage_date].strip
		balance		= match[:balance].gsub(/[\s,]/ ,"")
		return Debit.new(processDate, type, usageDate, source, amount, balance)
	end

	def debit_transfer_or_fee(match)
		processDate = match[:process_date].strip
		type 		= match[:type].strip
		usageDate 	= processDate
		source 		= ""
		amount 		= match[:amount].gsub(/[\s,]/ ,"")
		balance		= match[:balance].gsub(/[\s,]/ ,"")
		return Debit.new(processDate, type, usageDate, source, amount, balance)
	end

	def debit_atm_with(match)
		processDate = match[:process_date].strip
		source 		= match[:type].strip
		amount 		= match[:amount].gsub(/[\s,]/ ,"")
		type 		= match[:type].strip
		usageDate	= processDate
		balance		= match[:balance].gsub(/[\s,]/ ,"")
		return Debit.new(processDate, type, usageDate, source, amount, balance)
	end

  end #class
end #module
