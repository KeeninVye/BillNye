

class Debit
	def initialize(_pDate, _type, _uDate, _source, _amount, _balance)
		@pDate 	 = _pDate
		@type  	 = _type
		@uDate 	 = _uDate
		@source  = _source
		@amount  = _amount
		@balance = _balance
	end

	def to_string
		return"#{@pDate},#{@type},#{@uDate},#{@source},#{@amount}\n"
	end
	
	attr_reader :pDate
	attr_reader :type
	attr_reader :uDate
	attr_reader :source
	attr_reader :amount
	attr_reader :balance
end