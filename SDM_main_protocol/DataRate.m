function [rate, rate_lower, mcs_index] = DataRate(P_RX)
%This function computes the data rate and MCS index 
%   INPUTS:
%   1. P_RX: Received Power in absolute
%  OUTPUTS:
%   1. rate = User / Group data rate in Mbps
%   2. mcs_index = Corresponding MCS index
%   3. rate_lower = Next lower rate available in the given PHY mode

load global_params_incr;

valid_PHY_mode = 1;

if(P_RX < P_RX_min)
    rate = [];
    rate_lower = -10*1e6;
    mcs_index = -1;
    %'Unreachable Node - RX Power lower than Control Reqd.'
else

    %% RECEIVED POWER
    mcs_index = 0;
    mcs_lower_index = 0;

    %OBTAINING MCS INDEX
    if(strcmp(phy_mode,'SC-PHY'))
      if(P_RX < -68)
          mcs_index = 0;
      else
          valid_thresh = sense_thresh_SC(sense_thresh_SC <=P_RX);
          [value, ii] = min(abs(valid_thresh - P_RX));
          mcs_index = mcsMap_SC(valid_thresh(ii));
          mcs_lower_posn = find(mcsIndex_SC < mcs_index,1,'last');
          if(isempty(mcs_lower_posn)) 
              mcs_lower_index = 0;
          else
              mcs_lower_index = mcsIndex_SC(mcs_lower_posn);
          end
      end
    elseif(strcmp(phy_mode,'OFDM-PHY'))
        if(P_RX < -66)
          mcs_index = 0;
      else
          valid_thresh = sense_thresh_OFDM(sense_thresh_OFDM <=P_RX);
          [value, ii] = min(abs(valid_thresh - P_RX));
          mcs_index = mcsMap_OFDM(valid_thresh(ii));
          mcs_lower_posn = find(mcsIndex_OFDM < mcs_index,1,'last');
          if(isempty(mcs_lower_posn)) 
              mcs_lower_index = 0;
          else
              mcs_lower_index = mcsIndex_OFDM(mcs_lower_posn);
          end
        end
    elseif(strcmp(phy_mode,'LP-SC-PHY'))
        if(P_RX < -64)
          mcs_index = 0;
      else
          valid_thresh = sense_thresh_LP_SC(sense_thresh_LP_SC <=P_RX);
          [value, ii] = min(abs(valid_thresh - P_RX));
          mcs_index = mcsMap_LP_SC(valid_thresh(ii));
          mcs_lower_posn = find(mcsIndex_LP_SC < mcs_index,1,'last');
          if(isempty(mcs_lower_posn)) 
              mcs_lower_index = 0;
          else
              mcs_lower_index = mcsIndex_LP_SC(mcs_lower_posn);
          end
        end
    else
        fprintf('\n NOT A VALID PHY MODE: Please try again\n');
        valid_PHY_mode = 0;
    end

    %% OBTAINING DATA RATE
    if(valid_PHY_mode == 1)
        rate = mcsRateMap(mcs_index);
        rate_lower = mcsRateMap(mcs_lower_index);
    else
        rate = [];
        rate_lower =[];
    end
end


end

