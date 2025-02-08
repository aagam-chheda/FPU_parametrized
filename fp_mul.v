`include "fp_class.v"

module fp_mul(a,b,p,p_flags);
    input[n_exp+n_sig:0] a,b;
    output[n_exp+n_sig:0] p;
    output reg[last_flag-1:0] p_flags;

    `include "fp_parameters.v"

    wire signed[n_exp+1:0] a_exp,b_exp;
    reg signed[n_exp+1:0] p_exp,t1_exp,t2_exp;
    wire[n_sig:0] a_sig,b_sig;
    reg[n_sig:0] p_sig,t_sig;
    reg[n_exp+n_sig:0] p_temp;
    wire[2*n_sig+1:0] raw_sig;
    wire[last_flag-1:0] a_flags,b_flags;
    reg p_sign;

    fp_class a_class(a,a_exp,a_sig,a_flags);
    fp_class b_class(b,b_exp,b_sig,b_flags);

    assign raw_sig=a_sig*b_sig;

    always@(*)
        begin
            p_sign=a[n_exp+n_sig]^b[n_exp+n_sig];
            p_temp={p_sign,{n_exp{1'b1}},1'b0,{n_sig-1{1'b1}}};
            p_flags=6'b000000;

            if(a_flags[snan]|b_flags[snan])
                begin
                    p_temp=(a_flags[snan])?a:b;
                    p_flags[snan]=1;
                end

            else if(a_flags[qnan]|b_flags[qnan])
                begin
                    p_temp=(a_flags[qnan])?a:b;
                    p_flags[qnan]=1;
                end

            else if(a_flags[inf]|b_flags[inf])
                begin
                    if(a_flags[zero]|b_flags[zero])
                        begin
                            p_temp={p_sign,{n_exp{1'b1}},1'b1,{n_sig-1{1'b0}}};
                            p_flags[qnan]=1;
                        end
                    else
                        begin
                            p_temp={p_sign,{n_exp{1'b1}},{n_sig{1'b0}}};
                            p_flags[inf]=1;
                        end
                end

            else if((a_flags[zero]|b_flags[zero])||(a_flags[subnorm]&b_flags[subnorm]))
                begin
                    p_temp={p_sign,{n_exp+n_sig{1'b0}}};
                    p_flags[zero]=1;
                end

            else
                begin
                    t1_exp=a_exp+b_exp;

                    if(raw_sig[2*n_sig+1])
                        begin
                            t_sig=raw_sig[2*n_sig+1:n_sig+1];
                            t2_exp=t1_exp+1;
                        end
                    else
                        begin
                            t_sig=raw_sig[2*n_sig:n_sig];
                            t2_exp=t1_exp;
                        end

                    if(t2_exp<(emin-n_sig))
                        begin
                            p_temp={p_sign,{n_exp+n_sig{1'b0}}};
                            p_flags[zero]=1;
                        end
                    else if(t2_exp<emin)
                        begin
                            p_sig=t_sig>>(emin-t2_exp);
                            p_temp={p_sign,{n_exp{1'b0}},p_sig[n_sig-1:0]};
                            p_flags[subnorm]=1;
                        end
                    else if(t2_exp>emax)
                        begin
                            p_temp={p_sign,{n_exp{1'b1}},{n_sig{1'b0}}};
                            p_flags[inf]=1;
                        end
                    else
                        begin
                            p_exp=t2_exp+bias;
                            p_sig=t_sig;
                            p_temp={p_sign,p_exp[n_exp-1:0],p_sig[n_sig-1:0]};
                            p_flags[norm]=1;
                        end
                end
        end

    assign p=p_temp;
    
endmodule