module fp_class(f,f_exp,f_sig,f_flags);
    input[n_exp+n_sig:0] f;
    output reg signed[n_exp+1:0] f_exp;
    output reg signed[n_sig:0] f_sig;
    output[5:0] f_flags;

    `include "fp_parameters.v"

    wire exp_ones, exp_zeroes,sig_zeroes;

    assign exp_ones=&f[n_exp+n_sig-1:n_sig];
    assign exp_zeroes=!(|f[n_exp+n_sig-1:n_sig]);
    assign sig_zeroes=!(|f[n_sig-1:0]);

    assign f_flags[snan]=(exp_ones)&(!sig_zeroes)&(!f[n_sig-1]);
    assign f_flags[qnan]=(exp_ones)&(f[n_sig-1]);
    assign f_flags[inf]=(exp_ones)&(sig_zeroes);
    assign f_flags[zero]=(exp_zeroes)&(sig_zeroes);
    assign f_flags[subnorm]=(exp_zeroes)&(!sig_zeroes);
    assign f_flags[norm]=(!exp_ones)&(!exp_zeroes);

    reg[n_sig:0] mask=~0;
    reg[x-1:0] sa;  //shift amt

    integer i;

    always@(*)
        begin
            f_exp=f[n_exp+n_sig-1:n_sig];
            f_sig=f[n_sig-1:0];

            sa=0;

            if(f_flags[norm])
                {f_exp,f_sig}={f[n_exp+n_sig-1:n_sig]-bias,1'b1,f[n_sig-1:0]};
            else if(f_flags[subnorm])
                begin
                    for(i=(1<<(x-1));i>0;i=i>>1)
                        begin
                            if((f_sig)&(mask<<(n_sig+1-i))==0)
                                begin
                                    f_sig=f_sig<<i;
                                    sa=sa|i;
                                end
                        end

                    f_exp=emin-sa;
                end
        end
endmodule