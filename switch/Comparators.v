module Comparators
	#(
		// number of bits required to address the output ports
		parameter PORT_ADDR_LENGTH
	)
	(
		input wire [PORT_ADDR_LENGTH - 1 : 0] packet_addr,
		input wire [PORT_ADDR_LENGTH - 1 : 0] mem_data_all,

		// output wire [NUM_OF_PORTS - 1 : 0] eq
		output reg eq
	);

	always @ (*) begin
		eq = packet_addr == mem_data_all;
	end

endmodule