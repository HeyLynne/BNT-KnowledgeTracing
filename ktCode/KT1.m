
%root_dirname = '/Users/guoshuai/OneDrive/Lab/KnowledgeTracing/Code & Doc/data - paper/';
%Qdirname = 'Question/';
%Kdirname = 'PercentCorrect_2/';

root_dirname = 'D:\mine_project\code\Matlab\BNT-KT\';
Qdirname = 'Question\';
Kdirname = 'PercentCorrect_2\';

MAE_mat = zeros( 43, 2 );
Cor_mat = zeros( 43, 2 );
ll_mat = zeros(43, 2);

for fn = 43 : 43
    fns = num2str(fn)
    Qname = [ 'Q' fns '.txt'];
    Kname = [ 'K' fns '.txt'];
    Kname_non = [ 'K' fns '_non.txt' ];

    Qdata = load( [ root_dirname Qdirname Qname ] );
    [ ncases, ncol ] = size( Qdata );
    nQ = ncol - 2; % minus - ( student num, last Q )
    nS = ncases;

    K1_prior_data = load( [ root_dirname Kdirname Kname_non] );
    K1_prior_mat = [ 1 - K1_prior_data; K1_prior_data ];

    mK1_prior_data = load( [root_dirname Kdirname Kname] );
    mK1_prior_mat = [ 1 - mK1_prior_data(:,2); mK1_prior_data(:,2) ];


    fprintf('hmm\n');
    max_LLtrace = 0;
    for learn_rate = 0.1 : 0.01 : 0.2
        for forget_rate = 0 : 0.01 : 0.1
            trans_mat = [ 1 - learn_rate, learn_rate; forget_rate, 1 - forget_rate];
    %         trans_mat = [ 1 - learn_rate, learn_rate; 0, 1];
            [ hmm,  onodes,  K1class,  Kclass,  Qclass ]  = mk_hmm(  nQ, K1_prior_mat, trans_mat);
            training_cases  = cell( 2 * nQ, ncases );
            training_cases(  onodes, : )  = num2cell( Qdata( :, 2 : end - 1 )' );

            engine  = jtree_inf_engine( hmm );
            [ hmm,  LLtrace ] = learn_params_em( engine,  training_cases );
            obs_mat = get_field( hmm.CPD{ Qclass  }, 'cpt' )
            if obs_mat(1, 2) > 0.4 || obs_mat(2, 1) > 0.4
                continue;
            end

            if max_LLtrace == 0 ||  LLtrace(end) > max_LLtrace
                max_LLtrace = LLtrace(end);
                K1_prior_mat = get_field( hmm.CPD{ K1class }, 'cpt' );
                Klearn_mat   = get_field( hmm.CPD{ Kclass  }, 'cpt' );
                Qperform_mat = get_field( hmm.CPD{ Qclass  }, 'cpt' );
            end
        end
    end
    ll_mat(fn, 1) =  max_LLtrace;
    max_LLtrace
    K1_prior_mat
    Klearn_mat
    Qperform_mat
    fprintf('mhmm\n');
    max_LLtrace = 0;
    for learn_rate = 0.1 : 0.01 : 0.2
        for forget_rate = 0 : 0.01 : 0.1
            trans_mat = [ 1 - learn_rate, learn_rate; forget_rate, 1 - forget_rate];
%             trans_mat = [ 1 - learn_rate, learn_rate; 0, 1];
            [ mhmm, monodes, mK1class, mKclass, mQclass ] = mk_mhmm( nQ, nS, mK1_prior_mat, trans_mat );

            mtraining_cases = cell( 2 * nQ + 1, ncases );
            mtraining_cases( monodes, : ) = num2cell( Qdata( :, 1 : end - 1 )' );
            mengine = jtree_inf_engine( mhmm );
            [ mhmm, LLtrace ] = learn_params_em( mengine, mtraining_cases );

            obs_mat = get_field( mhmm.CPD{ mQclass  }, 'cpt' )
            if learn_rate == 0.1
                max_LLtrace = LLtrace(end);
                mK1_prior_mat = get_field( mhmm.CPD{ mK1class }, 'cpt' );
                mKlearn_mat = get_field( mhmm.CPD{ mKclass  }, 'cpt' );
                mQperform_mat = get_field( mhmm.CPD{ mQclass  }, 'cpt' );
                mKlearn_mat
            end

            if obs_mat(1, 2) > 0.4 || obs_mat(2, 1) > 0.4
                continue;
            end

            if max_LLtrace == 0 ||  LLtrace(end) > max_LLtrace
                max_LLtrace = LLtrace(end);
                mK1_prior_mat = get_field( mhmm.CPD{ mK1class }, 'cpt' );
                mKlearn_mat = get_field( mhmm.CPD{ mKclass  }, 'cpt' );
                mQperform_mat = get_field( mhmm.CPD{ mQclass  }, 'cpt' );
            end
        end
    end
    ll_mat(fn, 2) = max_LLtrace;
    max_LLtrace
    mK1_prior_mat;
    mKlearn_mat
    mQperform_mat

    %engine  = jtree_inf_engine( hmm );
    %mengine = jtree_inf_engine( mhmm );

    predict_perf = zeros( ncases, 5 );

    for i = 1 : ncases
        Qevidence = Qdata( i, 2 : end - 1 );

        K1prior_prob = K1_prior_mat(2);
        [ last_Klearned_prob, last_Qcorrect_prob ] = ...
            inf_last_KQ( Qevidence, K1prior_prob, Klearn_mat, Qperform_mat);

        MAE_mat( fn, 1 ) = MAE_mat( fn, 1) ...
           + abs( last_Qcorrect_prob - (Qdata( i, end ) -1) );

%         if Qdata( i, end ) - 1 == 0
%             MAE_mat( fn , 1 ) = MAE_mat( fn, 1 ) - last_Qcorrect_prob;
%         else
%             MAE_mat( fn , 1 ) = MAE_mat( fn, 1 ) + last_Qcorrect_prob;
%         end
%

        mK1prior_prob = mK1_prior_mat(i + nS);
        [ mlast_Klearned_prob, mlast_Qcorrect_prob ] = ...
            inf_last_KQ( Qevidence, mK1prior_prob, mKlearn_mat, mQperform_mat);
        MAE_mat( fn, 2 ) = MAE_mat( fn, 2 )...
           + abs( mlast_Qcorrect_prob - (Qdata( i, end ) - 1) );
%         if Qdata( i, end ) - 1 == 0
%             MAE_mat( fn, 2 ) = MAE_mat( fn, 2 ) - mlast_Qcorrect_prob;
%         else
%             MAE_mat( fn, 2 ) = MAE_mat( fn, 2 ) + mlast_Qcorrect_prob;
%         end
        predict_perf( i, 1 ) = Qdata( i, end ) - 1;
        predict_perf( i, 2 ) = last_Qcorrect_prob;
        predict_perf( i, 3 ) = mlast_Qcorrect_prob;
        predict_perf( i, 4 ) = last_Klearned_prob;
        predict_perf( i, 5 ) = mlast_Klearned_prob;
    end
    Cor_mat( fn, : ) = [ corr( predict_perf( :, 1 ), predict_perf( :, 2 ) ) ...
                         corr( predict_perf( :, 1 ), predict_perf( :, 3 ) ) ];

    MAE_mat( fn , :)
    Cor_mat( fn, : )

    xlswrite('c.xls',predict_perf)
end
format long g

% ll_mat
%
% MAE_mat
% length( find( MAE_mat( :, 1 ) > MAE_mat( :, 2 ) ) )
%
% Cor_mat
% mean( Cor_mat )

