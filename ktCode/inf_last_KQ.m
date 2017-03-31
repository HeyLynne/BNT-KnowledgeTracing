function [ last_Klearned_prob, last_Qcorrect_prob ] = inf_last_KQ( Qevidence, K1prior_prob, Klearn_mat, Qperform_mat )
    learn_rate = Klearn_mat( 1, 2 );
    guess_rate = Qperform_mat( 1, 2 );
    slip_rate  = Qperform_mat( 2, 1 );

    Klearned_prob = K1prior_prob;
    for e = Qevidence
        if e == 1  % incorrect
            Qincorrect_prob = Klearned_prob * slip_rate + ( 1 - Klearned_prob ) * ( 1 - guess_rate );
            Klearned_prob = Klearned_prob * slip_rate / Qincorrect_prob;
        else       % correct
            Qcorrect_prob = Klearned_prob * ( 1 - slip_rate ) + ( 1 - Klearned_prob ) * guess_rate;    
            Klearned_prob = Klearned_prob * ( 1 - slip_rate ) / Qcorrect_prob;
        end
        Klearned_prob = Klearned_prob + ( 1 - Klearned_prob ) * learn_rate;
    end
    last_Klearned_prob = Klearned_prob;
    last_Qcorrect_prob = Klearned_prob * ( 1 - slip_rate ) + ( 1 - Klearned_prob ) * guess_rate;
end

