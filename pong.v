module pong(
    //////////// CLOCK //////////
    input           MAX10_CLK1_50, // 50 MHz

    //////////// KEY //////////
    input     [1:0] KEY,          // KEY0, KEY1 (push-buttons, active-low)

    //////////// SW //////////
    input     [9:0] SW,           // use SW[0] for reset

    //////////// VGA //////////
    output    [3:0] VGA_B,
    output    [3:0] VGA_G,
    output          VGA_HS,
    output    [3:0] VGA_R,
    output          VGA_VS
);
    //------------------------------------------------
    // 1) Clock & Reset
    //------------------------------------------------
    wire clk        = MAX10_CLK1_50;
    wire async_rstn = ~SW[0];  // SW[0] is active-low reset
    wire sync_rstn;

    // Synchronize the external reset into the clk domain
    AsyncInputSynchronizer u_rst_sync (
        .clk   (clk),
        .asyncn(async_rstn),
        .syncn (sync_rstn)
    );


    //------------------------------------------------
    wire left_up     = ~KEY[0]; // W
    wire left_down   = ~KEY[1]; // S

    //------------------------------------------------
    // 3) VGA Sync signals
    //------------------------------------------------
    wire video_on, pixel_tick;
    wire [9:0] pixel_x, pixel_y;

    VGASync vsync_unit (
        .clk       (clk),
        .rstn      (sync_rstn),
        .hsync     (VGA_HS),
        .vsync     (VGA_VS),
        .video_on  (video_on),
        .p_tick    (pixel_tick),
        .pixel_x   (pixel_x),
        .pixel_y   (pixel_y)
    );

    //------------------------------------------------
    // 4) Pixel Generation (Pong logic)
    //------------------------------------------------
    wire [11:0] rgb_next;
    reg  [11:0] rgb_reg;

    PixelGen px_gen (
        .clk        (clk),
        .rstn       (sync_rstn),
        .video_on   (video_on),
        .p_tick     (pixel_tick),

        // Paddles: W/S for left, I/K for right
        .left_up    (left_up),
        .left_down  (left_down),

        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),

        // 4-bit R, G, B outputs
        .r          (rgb_next[11:8]),
        .g          (rgb_next[7:4]),
        .b          (rgb_next[3:0])
    );

    // Latch color on each pixel tick
    always @(posedge clk) begin
        if (pixel_tick)
            rgb_reg <= rgb_next;
    end

    // Assign final color to VGA outputs
    assign VGA_R = rgb_reg[11:8];
    assign VGA_G = rgb_reg[7:4];
    assign VGA_B = rgb_reg[3:0];

endmodule