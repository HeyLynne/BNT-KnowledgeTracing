function [ hmm, onodes, K1class, Kclass, Qclass ] = mk_hmm( nQ , K1_prior_mat, trans_mat)
    % graph struct
    N = 2 * nQ;
    dag = zeros( N, N ); 
    for i = 1 : nQ - 1
        dag( i, i + 1 ) = 1;
    end
    for i = 1 : nQ
        dag( i, i + nQ ) = 1;
    end
    % node size and type
    dnodes = 1 : N;
    node_sizes = 2 * ones( 1, N );
    hnodes = 1 : nQ;
    onodes = nQ + hnodes;

    K1class = 1; Kclass = 2; Qclass = 3;
    eclass = ones( 1, N );
    eclass( hnodes( 1) ) = K1class;
    eclass( hnodes( 2 : end ) ) = Kclass;
    eclass( onodes ) = Qclass;

    hmm = mk_bnet( dag, node_sizes, 'discrete', dnodes, ...
                    'observed', onodes, 'equiv_class', eclass);

    % parameter ( CPD )
    hmm.CPD{ K1class } = tabular_CPD( hmm, hnodes( 1 ), 'CPT', K1_prior_mat ); % prior
    hmm.CPD{ Kclass } = tabular_CPD( hmm, hnodes( 2 ) , 'CPT', trans_mat, 'adjustable', 0);  % transition matrix
    hmm.CPD{ Qclass } = tabular_CPD( hmm, onodes( 1 ) );  % observe 

end

