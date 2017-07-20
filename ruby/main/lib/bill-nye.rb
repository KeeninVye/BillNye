require_relative 'bill-nye/version'
require_relative 'bill-nye/bnlogger'
require 'date'
require 'csv'
require 'time'

module BillNye

  class BillNye

    def initialize()
    	@REGEX_PURCHASE = / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Card Purchase[a-zA-Z ]+)(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+)(?<amount>-[0-9]+.[0-9]{2}) +(?<balance>[,0-9]+\.[0-9]{2})/
    	@REX_TRANSFER 	= / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>[a-zA-Z .0-9#:]+) +(?<amount>[-0-9,]+.[0-9]{2}) +([0-9,]+.[0-9]{2})/
		@REX_PUR_RECUR 	= / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Recurring Card Purchase) (?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+)  (?<amount>[-0-9]+.[0-9]{2}) +(?<balance>[,0-9]+\.[0-9]{2})/
		@REX_PUR_RETURN = / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Purchase Return) +(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+)  (?<amount>[0-9]*.[0-9]{2}) +(?<balance>[,0-9]+\.[0-9]{2})/
		@REX_ATM_WITH 	= / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Non-Chase ATM Withdraw) +(?<usage_date>[0-9]{2}\/[0-9]{2}) (?<source>.+)  (?<amount>-[0-9]+.[0-9]{2}) +(?<balance>[0-9]+.[0-9]{2})/
		@REX_ATM_FEE 	= / +(?<process_date>[0-9]{2}\/[0-9]{2}) +(?<type>Non-Chase ATM Fee-With) +(?<amount>-[0-9]*.[0-9]{2}) +(?<balance>-[0-9]*.[0-9]{2})/
		@REX_CREDIT 	= /(?<process_date>[0-9]{2}\/[0-9]{2}) + (?<source>.+ )(?<amount>[0-9]+.[0-9]{2})/
		@REX_SAVINGS 	= / +SAVINGS SUMMARY/

		@log = BNLogger.log
    end

  	def parse_pdfs(dir)
  		Dir.foreach(dir) do |pdf|
  			begin
  				parse_pdf("#{dir}#{pdf}")
  			rescue
  				p "Failed to convert #{pdf} to text."
  			end
  		end
  	end

  	def parse_pdf(pdf)
		begin
			`pdftotext -layout #{pdf}`
			_match 		= /(?<filename>.+).pdf/.match(pdf)
			txt 		= "#{_match[:filename]}.txt"
			File.open("#{txt}", "r") do |file_handle|
				file_handle.each_line do |line|
					_line = parse_line(line)
				end
			end
		rescue
			p "Failed to convert #{pdf} to text."
		end
  	end

  	def parse_line(line)
  		begin
	  		if !@REGEX_PURCHASE.match(line).nil?
	  			_match 	= @REGEX_PURCHASE.match(line)
	  			_string = parse_default(_match)
		  		@log.info{"Match PURCHASE: #{_string}"}
	  		elsif !@REX_TRANSFER.match(line).nil?
	  			_match	= @REX_TRANSFER.match(line)
	   			_string = parse_default(_match)
		  		@log.info{"Match TRANSFER: #{_string}"}
	 		elsif !@REX_PUR_RECUR.match(line).nil?
	  			_match	= @REX_PUR_RECUR.match(line)
	  			_string = parse_default(_match)
		  		@log.info"PURCHASE RECURRING: #{_string}"
	  		elsif !@REX_PUR_RETURN.match(line).nil?
	  			_match	= @REX_PUR_RETURN.match(line)
	  			_string = parse_default(_match)
		  		@log.info{"PURCHASE RETURN: #{_string}"}
	  		elsif !@REX_ATM_WITH.match(line).nil?
	  			_match	= @REX_ATM_WITH.match(line)
	  			_string = parse_default(_match)
		  		@log.info{"Match ATM WITH: #{_string}"}
	  		elsif !@REX_ATM_FEE.match(line).nil?
	  			_match	= @REX_ATM_FEE.match(line)
	  			_string = parse_atm_fee(_match)
		  		@log.info{"ATM FEE: #{_string}"}
	  		elsif !@REX_CREDIT.match(line).nil?
	  			_match	= @REX_CREDIT.match(line)
	  			_string = parse_credit(_match)
		  		@log.info{"Match CREDIT: #{_string}"}
	  		#elsif !@REX_SAVINGS.match(line).nil?
	  			#Need to implement Savings regex
	  			#_match	= @REX_SAVINGS.match(line)
	  		end
	  	rescue
	  		@log.error{"Error on: #{line}"}
	  	end
  	end

	def parse_default(match)
		processDate = match[:process_date].strip
		source 		= match[:source].strip
		amount 		= match[:amount].strip
		type 		= match[:type].strip
		usageDate	= match[:usage_date].strip
		balance		= match[:balance].strip
		return "#{processDate},#{type},#{usageDate},#{source},#{amount},#{balance}"
	end

	def parse_credit(match)
		processDate = match[:process_date].strip
		source 		= match[:source].strip
		amount 		= match[:amount].strip
		return "#{processDate},#{source},#{amount}"
	end

	def parse_atm_fee(match)
		processDate = match[:process_date].strip
		source 		= match[:source].strip
		amount 		= match[:amount].strip
		type 		= match[:type].strip
		usageDate	= processDate
		balance		= match[:balance].strip
		return "#{processDate},#{type},#{usageDate},#{source},#{amount},#{balance}"
	end

    def process

	   	pdf = `pdftotext -layout pdf/2017-05-23.pdf`
	   	p pdf

    end

  end #class
end #module
