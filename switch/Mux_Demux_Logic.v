module Mux_Demux_Logic
	#(
		// number of output ports
		parameter NUM_OF_PORTS = 5,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH = 3,
		// number of data bits
		DATA_WIDTH = 8
	)
	(
		input wire [DATA_WIDTH - 1 : 0] packet_data,
		input wire packet_send,

		input wire [NUM_OF_PORTS - 1 : 0] eq,
		
		input wire [NUM_OF_PORTS - 1 : 0] port_received,

		output reg received,
		output reg [NUM_OF_PORTS - 1 : 0] port_request,
		output reg [NUM_OF_PORTS * DATA_WIDTH - 1 : 0] port_data
	);

	always @ (*) begin: port_request_block
		integer i;

		port_request = {NUM_OF_PORTS{1'b0}};
		port_data = {NUM_OF_PORTS * DATA_WIDTH{1'b0}};

		if (packet_send == 1'b1) begin
			for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
				if (eq[i] == 1'b1) begin
					port_request[i] = 1'b1;
					port_data[i * DATA_WIDTH +: DATA_WIDTH] = packet_data;
				end
			end
		end
	end

	always @ (*) begin: received_block
		integer i;

		received = 1'b0;

		if (packet_send == 1'b1) begin
			for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
				if (eq[i] == 1'b1 && port_received[i] == 1'b1) begin
					received = 1'b1;
				end
			end
		end
	end
endmodule