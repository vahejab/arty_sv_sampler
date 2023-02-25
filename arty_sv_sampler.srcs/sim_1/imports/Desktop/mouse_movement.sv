module mouse_movement (
    input wire clk,
    input wire rst,
    input wire [15:0] x_displacement,
    input wire [15:0] y_displacement,
    input wire [7:0] wheel_displacement,
    output wire [15:0] x_movement,
    output wire [15:0]  y_movement,
    output wire [7:0]  wheel_movement
);

reg [15:0] x_count, y_count, wheel_count;

always @(posedge clk) begin
    if (rst) begin
        x_count <= 0;
        y_count <= 0;
        wheel_count <= 0;
    end else begin
        x_count <= x_count + x_displacement;
        y_count <= y_count + y_displacement;
        wheel_count <= wheel_count + wheel_displacement;
    end
end

assign x_movement = x_count[15];
assign y_movement = y_count[15];
assign wheel_movement = wheel_count[15];

endmodule