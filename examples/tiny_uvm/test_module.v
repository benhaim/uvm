module dut();

    logic some_bit;

    initial some_bit = 0;

    initial forever begin
        int some_delay = $urandom_range(2,4000);
        #(some_delay * 1ns);
        some_bit = ~some_bit;
    end

    initial begin
        #30us;
        $finish();
    end

    always @(some_bit)
        $info("some_bit changed to %b",some_bit);

endmodule
