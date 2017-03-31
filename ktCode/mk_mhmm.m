function [ mhmm, onodes, K1class, Kclass, Qclass ] = mk_mhmm( nQ, nS, K1_prior, trans_mat )
    % graph struct
    N = 1 + 2 * nQ;
    dag = zeros( N, N );
    for i = 1 : nQ
        dag( i, i + 1 ) = 1;
    end
    for i = 1 + ( 1 : nQ )
        dag( i, i + nQ ) = 1;
    end

    % node size and type
    dnodes = 1 : N;
    node_sizes = 2 * ones( 1, N );
    node_sizes(1) = nS;
    hnodes = 1 + ( 1 : nQ );
    onodes = [1  nQ + hnodes ];

    Sclass = 1; K1class = 2; Kclass = 3; Qclass = 4;
    eclass = ones( 1, N );
    eclass( onodes( 1 ) ) = Sclass;
    eclass( hnodes( 1 ) ) = K1class;
    eclass( hnodes( 2 : end ) ) = Kclass;
    eclass( onodes( 2 : end ) ) = Qclass;

    mhmm = mk_bnet( dag, node_sizes, 'discrete', dnodes, ...
                    'observed', onodes, 'equiv_class', eclass );

    S_prior = ones(1, nS) / nS;
    mhmm.CPD{ Sclass }  = tabular_CPD( mhmm, onodes( 1 ), 'CPT', S_prior, 'adjustable', 0 );
    mhmm.CPD{ K1class } = tabular_CPD( mhmm, hnodes( 1 ), 'CPT', K1_prior, 'adjustable', 0 );
    mhmm.CPD{ Kclass }  = tabular_CPD( mhmm, hnodes( 2 ), 'CPT', trans_mat, 'adjustable', 0 );
    mhmm.CPD{ Qclass }  = tabular_CPD( mhmm, onodes( 2 ) );
end

