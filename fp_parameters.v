parameter n_exp=8;
parameter n_sig=23;
parameter x=5;          //x=4 for hp, x=5 for sp, x=6 for dp, x=7 for qp

parameter bias=((1<<(n_exp-1))-1);
parameter emin=1-bias;  //emin is the smallest normal exponent
parameter emax=bias;    //emax is the largest normal exponent

parameter norm=0;
parameter subnorm=norm+1;
parameter zero=subnorm+1;
parameter inf=zero+1;
parameter qnan=inf+1;
parameter snan=qnan+1;
parameter last_flag=snan+1;