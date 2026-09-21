module Controller
	#(
		// number of output ports
		parameter NUM_OF_PORTS,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH,
		// number of data bits
		DATA_WIDTH
	)
	(
		input wire clk,
		input wire reset,

		input wire packet_send_req,
		input wire port_found,
		input wire received,

		output reg memory_blocked,
		output reg packet_finished,
		output reg packet_send
	);

	reg [1:0] state;

	always @ (*) begin
		if (reset) begin
			state <= 0;
		end

		case (state)
			0: begin
				if (packet_send_req == 1'b1) begin
					state <= 1;
				end
			end
			1: begin
				state <= 2;
			end
			2: begin
				if (port_found == 1'b0) begin
					state <= 0;
				end else begin
					state <= 2;
				end
			end
			3: begin
				if (received == 1'b1) begin
					state <= 0;
				end
			end

			default: state <= 0;
		endcase
	end

	always @ (state) begin
		case (state)
			0: begin
				memory_blocked <= 0;
				packet_finished <= 0;
				packet_send <= 0;
			end
			1: begin
				memory_blocked <= 1;
				packet_finished <= 0;
				packet_send <= 0;
			end
			2: begin
				memory_blocked <= 1;
				packet_finished <= 0;
				packet_send <= 1;
			end
			3: begin
				memory_blocked <= 1;
				packet_finished <= 1;
				packet_send <= 0;
			end

			default: begin
				memory_blocked <= 0;
				packet_finished <= 0;
				packet_send <= 0;
			end
		endcase
	end
endmodule