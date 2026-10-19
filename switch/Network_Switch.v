module Network_Switch
	#(
		// number of output ports
		parameter NUM_OF_PORTS = 5,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH = 3,
		// number of data bits
		DATA_WIDTH = 8
	)
	(
		input wire clk,
		input wire reset,

		// index portu do paměti adres
		input wire [$clog2(NUM_OF_PORTS) - 1 : 0] mem_port_index,	
		// adresa portu (lze sloučit s packet_addr)
		input wire [PORT_ADDR_LENGTH - 1 : 0] mem_port_addr,
		// zápis do paměti adres portů
		input wire mem_write_enable,

		// data paketu
		input wire [DATA_WIDTH - 1 : 0] packet_data,
		// cílová adresa paketu
		input wire [PORT_ADDR_LENGTH - 1 : 0] packet_addr,
		// požadavek na odeslání paketu
		input wire packet_send_req,
		// paket byl zahozen/odeslán
		output wire packet_finished,
	
		// (pro každý port) požadavek na odeslání paketu
		output wire [NUM_OF_PORTS - 1 : 0] port_req,
		// (pro každý port) data paketu
		output wire [NUM_OF_PORTS * DATA_WIDTH - 1 : 0] port_data,
		// (pro každý port) paket byl přijat cílovým zařízením
		input wire [NUM_OF_PORTS - 1 : 0] port_received
	);

	// -----
	// internal wires for interconnecting the modules
	wire [NUM_OF_PORTS * PORT_ADDR_LENGTH - 1 : 0] mem_data_all;
	wire [NUM_OF_PORTS - 1 : 0] eq;

	wire port_found;
	wire packet_send;
	wire received;

	// notifying memory that it should not accept any write requests
	wire memory_blocked;

	// -----
	// Memory block for storing the routing port addresses, indexed by port index
	Memory #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH)
	) memory (
		.clk(clk),
		.reset(reset),
		.port_index(mem_port_index),
		.port_addr(mem_port_addr),
		.write_enable(mem_write_enable),
		.memory_blocked(memory_blocked),
		.data(mem_data_all)
	);

	// -----
	// Comparators for port address match
	Comparators #(
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.NUM_OF_PORTS(NUM_OF_PORTS)
	) compare (
		.packet_addr(packet_addr),
		.mem_data_all(mem_data_all),
		.eq(eq)
	);

	// -----
	// Any address match block
	Or #(
		.NUM_OF_PORTS(NUM_OF_PORTS)
	) or_block (
		.eq(eq),
		.match(port_found)
	);

	// -----
	// Controller determining control signals for whole network switch
	Controller #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.DATA_WIDTH(DATA_WIDTH)
	) controller (
		.clk(clk),
		.reset(reset),
		.packet_send_req(packet_send_req),
		.port_found(port_found),
		.received(received),
		.memory_blocked(memory_blocked),
		.packet_finished(packet_finished),
		.packet_send(packet_send)
	);

	// -----
	// Mux/Demux logic for routing packets to the correct ports
	Mux_Demux_Logic #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.DATA_WIDTH(DATA_WIDTH)
	) mux_demux_logic (
		.packet_data(packet_data),
		.packet_send(packet_send),
		.eq(eq),
		.port_received(port_received),
		.received(received),
		.port_request(port_req),
		.port_data(port_data)
	);

endmodule