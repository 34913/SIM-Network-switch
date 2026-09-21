module Or
	#(
		// number of output ports
		parameter NUM_OF_PORTS
	)
	(
		input wire [NUM_OF_PORTS - 1 : 0] eq,

		output reg match
	);

	always @ (*) begin: or_block
		integer i;
		// match = {NUM_OF_PORTS{1'b0}};
		match = 0;
		for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
			match = match | eq[i];
		end
	end

endmodule